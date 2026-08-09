---
id: ADR-210
title: Asynchronous notification/email delivery — transactional outbox pattern
status: Approved
category: Integration
version: "1.0"
date: 2026-08-09
deciders: Platform Engineering
related:
  architecture:
    - APP-020
  standards: []
  current_state: []
  reference: []
  runbooks: []
  adrs:
    - ADR-090
    - ADR-100
    - ADR-130
    - ADR-200
supersedes: []
superseded_by: null
---

# ADR-210 — Asynchronous notification/email delivery: transactional outbox pattern

**Status: Approved (1.0), 2026-08-09.** GHS's implementation of this pattern is separate, subsequent work — this ADR establishes the platform-wide decision; it does not itself implement anything in GHS or RMS.

## Context

GHS's real, live email-sending code (`apps/api/src/lib/email.ts` and 9 call sites across `auth/register.ts`, `auth/passwordReset.ts`, `handicap.ts`, `rounds.ts`, `players.ts`, `admin/users.ts`) sends email synchronously, inline in the HTTP request path, with no retry and no durability against a provider outage — a failed send is simply logged to `notification_history` as `failed` and never attempted again. GHS's worker (`apps/worker/src/worker.ts`) currently does nothing functional — a heartbeat stub with no database access.

RMS already has two independent, real, production-run implementations of an outbox/async-delivery pattern in `apps/worker/engine/`:
- **`email_outbox`** (`outbox.py`) — a simple generic table (`status: pending/sent/failed`, `attempts`), processed via `SELECT ... FOR UPDATE SKIP LOCKED` batch claiming, fixed retry-max, no scheduled backoff.
- **`reminder_dispatches`** (`delivery.py`/`poller.py`/`fanout.py`) — a more sophisticated, multi-channel (email + SMS) scheduled-dispatch system with a pluggable `ChannelAdapter` abstraction, `system_settings`-configurable backoff (`dispatch_retry_backoff_minutes`, default `[1, 5, 15]` minutes), `retry_after`-based re-attempt scheduling, permanent failure after backoff exhaustion, and `failure_reason` capture. Both are tested (`test_retry_backoff.py`, `test_delivery_smtp.py`) and both have run in production — `reminder_dispatches` is what sent the real emails during the incident flagged earlier in this engagement.

No ADR, standard, or `reference/` category currently covers this anywhere in `socx-platform` — confirmed by direct search of every category (`application`, `deployment`, `github`, `monitoring`, `nginx`, `security`, `systemd`, `terraform`). `ADR-100` (default integration style) explicitly scoped *cross-system* asynchronous/event-driven integration as "out of scope until a concrete use case needs it, at which point it is recorded as a new ADR rather than added quietly" — this is that ADR, though it is worth being precise that this is a different concern: `ADR-100` governs integration *between* SOCX applications; this ADR governs a single application's *internal* handling of its own outbound communication to an external third-party (an email provider), via its own worker. It doesn't revisit `ADR-100`'s ruling, only fulfils its stated intent to make async decisions explicit when a real case arrives.

The platform owner has reviewed the prior evaluation and directed that this proceed as a Platform Evolution ADR, explicitly treating RMS's existing implementations as **evidence and reference material, not architectural authority** — the same clean-slate principle governing the rest of the GHS redevelopment applies here too.

## Decision

The platform adopts **transactional outbox** as the default pattern for application-generated, asynchronously-delivered notifications (initially email; the pattern is not email-specific by construction):

**API business transaction → durable outbox record (same DB transaction) → background worker (poll + claim + send) → external provider.**

The subsections below address each required design concern. Each is tagged with where the decision sits:
- **[Platform principle]** — binding on every application that adopts this pattern.
- **[Learned from RMS]** — informed by RMS's real, working implementation, adapted rather than copied. Where a decision below improves on what RMS currently does, that is stated explicitly — RMS's implementation is evidence that the pattern works in production, not a specification to conform to.
- **[App implementation choice]** — the platform sets a default or a floor; the specific application decides the rest.
- **[GHS-specific]** — applies to GHS's adoption of this ADR, not a platform-wide requirement.

A [Platform principle] is occasionally evidenced by an existing, working implementation other than RMS's (for example, GHS's own current provider-abstraction code, point 10) — this is still evidence informing a platform-wide decision, not a fifth category; it is called out inline where it applies.

**State model** (referenced throughout, defined once here to keep the failure/retry/concurrency sections unambiguous): every outbox record is in exactly one of four states — `pending` (eligible for claiming once any `retry_after` has elapsed), `processing` (claimed by a worker, attempt in progress), `sent` (terminal — success), `failed` (terminal — permanent failure or retries exhausted). The literal state names and column names are an **[App implementation choice]**; the four-state shape and the transitions below are the **[Platform principle]**.

### 1. Transactional integrity **[Platform principle]**

The outbox record MUST be created in the same database transaction as the business operation that triggers it (e.g. the `UPDATE rounds SET status = 'approved'` and the `INSERT INTO <outbox>` happen in one transaction, committed or rolled back together). This is the entire point of "transactional" outbox — without it, the pattern degrades to "fire an async job and hope," which does not improve on GHS's current synchronous-and-unretried behaviour in any way that matters. Neither of RMS's two implementations was inspected deeply enough during discovery to confirm this is enforced consistently there today — this ADR states it as a requirement going forward regardless of what RMS currently does, per the clean-slate/reference-not-authority principle.

### 2. At-least-once delivery semantics **[Platform principle]**

The platform accepts **at-least-once** delivery as the standard guarantee, not exactly-once, and accepts this **deliberately, as a residual risk, not as an oversight**. Two mechanisms in this ADR can each independently produce a duplicate: (a) a crash between "provider accepted the send" and "worker marks the row `sent`," and (b) the crash-recovery sweep (point 7) reclaiming a `processing` row whose send may in fact have already succeeded. Both are accepted rather than engineered away, on the basis of proportionality: a duplicate transactional email (e.g. receiving a round-approval notice twice) is a low-severity, user-visible-but-recoverable inconvenience, not a correctness, safety, or financial defect. Building for exactly-once (e.g. two-phase commit with the provider) is rejected as disproportionate to this — see Alternatives Considered. Point 3 defines the best-effort mitigation available; it reduces but does not eliminate this risk.

### 3. Idempotency / duplicate protection **[Platform principle, floor]; [App implementation choice, ceiling]**

Every outbox record MUST carry a stable identity (its own primary key is sufficient) that can be used as an idempotency key if the provider supports one (e.g. SendGrid/SES both accept a client-supplied message ID for de-duplication on their side). Where the provider supports it, the worker SHOULD pass it. Where it doesn't (e.g. plain SMTP, used for local/Mailpit development), no further protection is available at the provider level — the at-least-once trade-off (point 2) applies in full, and this is accepted rather than solved with heavier machinery (e.g. a provider-independent sent-confirmation handshake). This is a floor, not a ceiling: an application MAY add stronger protection if it has a specific need, but none is required by default.

### 4. Retryable versus permanent failures **[Platform principle — a deliberate improvement over RMS's current practice]**

Neither of RMS's current implementations distinguishes failure *types* — both retry every failure identically up to a maximum, then give up. This ADR requires the distinction: the worker classifies a provider error as **permanent** (e.g. invalid recipient address, provider-rejected content, `4xx`-style hard rejection where the provider's API distinguishes this) or **retryable** (timeouts, `5xx`/connection errors, rate-limiting). Permanent failures move directly to `failed` without consuming retry attempts; retryable failures follow the backoff schedule (point 5). The specific classification rules are an **[App implementation choice]**, since they depend on the provider's actual error surface, but the pending/permanent distinction itself is a platform requirement.

### 5. Retry/backoff strategy **[Learned from RMS, refined]**

Adopt RMS's `reminder_dispatches` design: a configurable backoff schedule expressed as a list of minute-offsets, stored in the consuming application's own `system_settings` (per `APP-020`), defaulting to RMS's proven `[1, 5, 15]` minutes if the application defines nothing else. `retry_after` timestamp on the record; a row is only eligible for re-claim once `retry_after <= NOW()`. After the backoff list is exhausted, the record becomes `failed` (point 11). The schedule itself, and how many attempts it represents, is an **[App implementation choice]** — the mechanism (configurable, stored in `system_settings`, not hardcoded) is the **[Platform principle]**.

### 6. Concurrent worker processing **[Platform principle, direct from RMS]**

`SELECT ... FOR UPDATE SKIP LOCKED` for batch claiming, exactly as both of RMS's implementations already do. This is the standard, proven mechanism for safe concurrent claiming against PostgreSQL and requires no platform-level modification — adopted directly, not merely "informed by." The platform principle stops at the claiming mechanism itself: batch size and poll interval are **[App implementation choice]** (RMS makes its own poll interval runtime-configurable via `system_settings`, per `APP-020` — a sensible default for any application adopting this pattern, but not mandated by this ADR).

### 7. Worker crash/recovery after a message has been claimed **[Platform principle — a gap in RMS's current practice, closed here]**

`FOR UPDATE SKIP LOCKED` protects against two workers claiming the *same* row concurrently, but the lock is held only for the duration of the claiming transaction — RMS's current `outbox.py` claims and commits status changes within the same short transaction per row, which limits exposure but doesn't fully eliminate it if a worker crashes mid-send (after the provider call, before the status update commits). This ADR requires that outbox records carry an explicit **`processing`** status set at claim time (separate from `pending` and the terminal `sent`/`failed`), plus a `claimed_at` timestamp. A monitoring/recovery sweep (part of the worker's own poll cycle, not a separate process) reclaims any row stuck in `processing` beyond a defined timeout (e.g. a small multiple of expected provider-call latency), so a crashed worker's claimed-but-unfinished work is not silently lost.

**This reclaim MUST be treated as a failed attempt, not a free retry.** A stuck-`processing` row is put through the same logic as any other failure (point 4/5): its `attempts` counter is incremented, and it is routed back to `pending` with the next backoff delay applied if attempts remain, or to `failed` if the backoff schedule is exhausted. Treating a reclaim as consequence-free (resetting straight to `pending` with no attempts increment) would let a message that reliably crashes the worker on every attempt — a poison message — loop indefinitely, which is precisely the "permanently stranded work" this section exists to prevent, just inverted into an infinite loop instead of a stall. Since the worker cannot know whether the crash happened before or after the provider actually sent the message, this reclaim path is conservatively classified as **retryable, never permanent** (point 4) — it is exactly the mechanism point 2 already names as a second source of possible duplicate delivery, accepted for the same proportionality reason.

This directly closes a real gap neither RMS implementation currently has.

### 8. Outbox retention and cleanup **[Platform principle — undecided in RMS today, decided here]**

Neither RMS implementation currently has any retention/archival policy — rows accumulate indefinitely. This ADR requires that every terminal record (`sent` or `failed`) be retained for a bounded period rather than indefinitely, deleted or archived by a scheduled job (the same worker, on a slower cadence, is sufficient — no separate tooling required).

**`sent` and `failed` records are not required to share the same retention period.** A `failed` (dead-letter, per point 11) record plausibly warrants longer retention than a `sent` one — it may still need manual investigation, re-queuing, or support follow-up after a `sent` record of the same age would already be safe to discard. Whether they actually differ, and by how much, is not decided here.

**The specific retention period(s) are a business/compliance question, not an engineering one** — this ADR deliberately does not set a number for either status (see Deferred to Application-Level Decision) rather than guessing. What this ADR does establish is the principle: retention must be bounded and explicit, and the `sent`/`failed` split is at minimum a question the implementing application must answer and present for approval, not an assumption that one number fits both.

### 9. Observability **[Platform principle]**

At minimum, all queryable directly from the outbox table's own columns, with no new infrastructure required to produce them:
- **Queue depth** — `COUNT(*) WHERE status = 'pending'`.
- **Queueing latency** — oldest-pending-record age (`NOW() - created_at` for the oldest `pending` row): how long work waits before a worker even picks it up.
- **Processing/delivery latency** — distinct from queueing latency: `sent_at - claimed_at` (or `last_attempt_at - claimed_at` for failures) for completed attempts, measuring how long the send itself takes once claimed.
- **Retry activity** — `attempts` distribution across in-flight (`pending` with `attempts > 0`) records.
- **Permanently failed count** — `COUNT(*) WHERE status = 'failed'` (this is the dead-letter count, point 11).

These should be exposed through whatever the application already uses for `reference/monitoring` (uptime/health-check pattern already Approved and live for both RMS and GHS's domains) rather than inventing new tooling. A `failed`-count threshold alert is the minimum viable monitoring requirement; anything richer is an **[App implementation choice]**.

### 10. Provider abstraction **[Platform principle]**

The worker's send step MUST be abstracted behind a provider-agnostic interface — no outbox or worker logic may be coupled to a specific provider's SDK, API shape, or error format beyond that boundary. This is a platform principle, not a GHS-specific detail; it is evidenced by (not "learned from RMS," but from GHS's own existing code, called out per the note under the classification legend above) GHS's `apps/api/src/lib/email.ts`, which already defines exactly this: an `EmailProvider` type (`mailpit | smtp | sendgrid | ses | mock`) selected at runtime via configuration, with the actual send call abstracted behind a single internal interface. This is real, existing, working abstraction — **[GHS-specific]** implementation detail: GHS reuses it as-is for the worker's send step rather than rebuilding it; other applications adopting this ADR are not required to use GHS's specific interface, only to satisfy the same provider-independence principle. RMS's `ChannelAdapter` (`ABC` with `EmailAdapter`/`SmsAdapter` implementations) is a similar idea at a slightly different layer (channel, not just provider) — worth noting as a **future** extension point if a non-email channel is ever genuinely needed, but not built speculatively now (see Alternatives Considered).

### 11. Permanent failure / dead-letter handling **[Platform principle, direct from RMS's practice]**

**Definition, precise to this architecture:** "dead-letter" does not refer to a separate structure. It refers to any outbox row whose `status = 'failed'` — a self-describing, terminal, in-place state, queryable exactly like any other row (see point 9's permanently-failed-count metric). No separate dead-letter table, topic, or queue is introduced; the outbox table is the dead-letter store, distinguished only by status value. This matches RMS's existing practice and keeps the design operationally simple (directly serving point 12's proportionality question) — a second table or mechanism is not justified by anything found in GHS's or RMS's real requirements. Any `failed` record MUST be re-queueable only via an explicit, audited admin action (reset to `pending`, logged) — never automatically, and never as a side effect of the crash-recovery sweep (point 7), which only ever reclaims `processing` rows, not `failed` ones.

### 12. When PostgreSQL-as-queue stops being appropriate **[Platform principle — explicit threshold, so this is a deliberate future decision, not a silent one]**

PostgreSQL-as-outbox remains appropriate as long as: throughput stays well below what `SKIP LOCKED` polling comfortably handles (low thousands of messages/hour is a conservative, generous ceiling for a single-table poll design — GHS and RMS's combined realistic volume is nowhere near this); a single, generous poll interval (seconds, not sub-second) meets latency needs (transactional email does not need sub-second delivery); no genuine fan-out/pub-sub requirement exists (one event → one or a small, fixed number of recipients, not one event → many independent subscribed consumers); and no cross-application/cross-datastore delivery requirement exists (the outbox always lives in the same database as the application that owns it). If any of these stop holding — meaningfully higher volume, a real pub-sub/fan-out need, or genuine sub-second latency requirements — that is the trigger for a **new, dedicated ADR** evaluating a message broker, not a silent migration. No such trigger exists today for either GHS or RMS.

### Notification history vs. outbox — explicit decision, not an implementation shortcut

Per the platform owner's direction, these are evaluated as genuinely separate concerns before any conclusion:

- **The outbox** represents *work to be delivered* — a technical record with a processing lifecycle (`pending → processing → sent/failed`), owned by the worker, largely uninteresting to a human once delivery succeeds.
- **Notification history** (GHS's existing table) represents the *business/user-facing record* of what was communicated to whom — relevant to admins investigating "did this player get notified," support queries, and potentially the user themselves ("your notifications"). Its natural audience and its natural lifetime are different from the outbox's.

**Options evaluated:**
1. **Single merged table** — extend `notification_history` with the outbox's technical columns (`attempts`, `claimed_at`, `retry_after`, `processing` status). Simpler schema, one source of truth, avoids a join. Risk: conflates a short-lived technical processing record with a business record that may need a longer, different retention policy (point 8) — the retention question doesn't have one right answer for both purposes, but a merged table forces one.
2. **Fully separate tables**, linked by a foreign key — the outbox row is purely technical and can be aggressively retained/pruned (point 8) independent of `notification_history`, which can keep its own, likely longer, business-appropriate retention. Requires a join for any view that needs both ("what was sent and did it actually deliver"), and requires the API layer to write both a `notification_history` row (business decision: this notification happened) and an outbox row (technical: please deliver it) — slightly more write coordination, still within the same transaction (point 1).
3. **Outbox only, no separate history** — reject: loses the deliberate, already-correct `notification_preferences` gating and the business-level "what was communicated" record that has real value independent of delivery mechanics.

**Decision: Option 2 — kept separate, linked by a foreign key.** The retention mismatch under option 1 is a real, structural problem (point 8 already establishes the outbox needs bounded retention, plausibly different for `sent` vs. `failed`, while a business notification history plausibly wants its own, likely longer, retention for audit/support purposes — collapsing all of that onto one table forces a single, wrong-for-some-purpose answer). The extra write and join cost is small and stays within the existing transactional boundary. This is a considered decision specific to this ADR, distinct from and correcting the earlier evaluation's premature lean toward merging.

**Relationship, made unambiguous:** the outbox row is the child, `notification_history` is the parent. The business decision ("this event happened, a notification is warranted") is logically prior to the technical delivery task, so the outbox record carries a `notification_history_id` foreign key back to the row that caused it, not the reverse. Both rows are written in the same transaction as the triggering business operation (point 1) — `notification_history` first (or concurrently, since both are in one transaction and ordering within it has no observable effect), the outbox row second, referencing it. A `notification_history` row MAY exist with no outbox row at all (e.g. `notification_preferences` gated it out before any delivery was ever attempted, matching GHS's existing `skipped` status) — the foreign key is therefore nullable-from-the-outbox-side in the sense that not every history row has a corresponding delivery task, but never the other way around: an outbox row always has exactly one owning `notification_history` row.

### Classification summary

| Concern | Platform-wide principle | Learned from RMS | App implementation choice | GHS-specific |
|---|---|---|---|---|
| Transactional creation (1) | Yes | — | — | — |
| At-least-once semantics (2) | Yes | Matches RMS's existing trade-off | — | — |
| Idempotency floor (3) | Yes (floor) | — | Stronger protection, if needed | — |
| Retryable vs. permanent (4) | Yes (the distinction itself) | — | Classification rules | — |
| Backoff mechanism (5) | Yes (configurable, in `system_settings`) | RMS's `[1,5,15]` default | The actual schedule | — |
| `SKIP LOCKED` claiming (6) | Yes | Direct from RMS | — | — |
| Crash recovery sweep + counts as an attempt (7) | Yes | Gap in RMS, closed here | Timeout value | — |
| Retention (8) | Yes (bounded; `sent`/`failed` need not match) | RMS has none today | Actual period(s) — deferred, present for approval | — |
| Observability (9) | Yes (minimum fields, incl. queueing vs. processing latency) | — | Richer dashboards | — |
| Provider abstraction (10) | Yes (independence is the principle) | — | — | Evidenced by, and reused from, GHS's own existing `EmailProvider` |
| Dead-letter (11) | Yes (in-place `failed` status, no new structure) | Direct from RMS's practice | — | — |
| Broker threshold (12) | Yes (explicit trigger conditions) | — | — | — |
| History vs. outbox split | Yes (kept separate; outbox → `notification_history` FK) | — | — | — |

## Alternatives Considered

- **Message broker (SQS/RabbitMQ/etc.) from the start** — Rejected: no platform reference exists for one, GHS and RMS's combined realistic volume is nowhere near where Postgres-as-queue becomes a bottleneck (point 12), and it introduces a new operational dependency, credential surface, and monitoring requirement for no evidenced benefit — directly against the platform's operational-simplicity discipline (same reasoning `ADR-100` already applied when rejecting async-as-default platform-wide).
- **Adopt RMS's `reminder_dispatches`/multi-channel `ChannelAdapter` machinery wholesale** — Rejected as the default: more sophistication (scheduled/recurring dispatch, multi-channel SMS abstraction) than the transactional-email use case requires. Its backoff/scheduling *ideas* are adopted; its full machinery is not, per this ADR's own clean-slate principle applied to RMS specifically, not just to legacy GHS.
- **Adopt RMS's simpler `email_outbox` unmodified** — Rejected as insufficient: lacks the retryable/permanent distinction (point 4), a crash-recovery sweep (point 7), and any retention policy (point 8) — all real gaps this ADR closes rather than silently inherits.
- **Merge notification history and outbox into one table** — Rejected; see the explicit evaluation above.
- **Exactly-once delivery** (e.g. two-phase commit with the provider) — Rejected: no mainstream email provider supports this, and building application-level compensation for it is disproportionate to a transactional-email use case; at-least-once with idempotency-key best-effort (point 3) is the industry-standard, proportionate answer.

## Consequences

- GHS's implementation of this pattern becomes the **second real, independent validation** — after RMS's own two implementations — but is not a copy of either; it closes gaps (points 4, 7, 8) neither RMS implementation currently addresses.
- Once GHS implements this, the platform has a real basis to consider formalising a `reference/messaging` (or similarly named) category, and to consider whether RMS's own two implementations should eventually consolidate onto the same pattern — that consolidation is RMS's own future backlog decision, not created or implied by this ADR.
- This directly advances `APP-020` (Configuration Management) — the backoff schedule belongs in `system_settings`, a second real cross-app case for that pattern's own eventual graduation.
- No GHS or RMS implementation work proceeds until this ADR is reviewed and approved, per the platform owner's explicit instruction.

## Deferred to Application-Level Decision (resolved by the platform owner, 2026-08-09 — not further open questions)

These are not gaps in this ADR — they are deliberately scoped **out** of it, per the platform owner's explicit direction, and must each be presented back for approval as explicit implementation decisions when an application (starting with GHS) actually implements this pattern, rather than being silently selected by whoever writes the code:

1. **Outbox `sent` retention period (point 8).** Left as an application/business/compliance decision. No platform-wide number is set by this ADR, and none should be inferred from RMS's (nonexistent) practice.
2. **Outbox `failed` retention period (point 8).** Likewise an application/business/compliance decision, independent of (1) — this ADR retains the principle that `failed` records may legitimately need longer retention than `sent` ones for investigation, without mandating that they do.
3. **`notification_history` retention period.** Independent of both (1) and (2) — kept separate per this ADR's Decision above — and equally left to application/business/compliance judgement.
4. **Crash-recovery timeout (point 7) and retry/backoff schedule (point 5).** Remain application-level implementation choices. RMS's `[1, 5, 15]`-minute default is documented as *evidence that a working value exists*, not elevated into a platform-mandated default — an application MAY use it, is not required to, and MAY choose differently with its own justification.

Everything else in this ADR is a platform-wide stated decision, not deferred — see the Classification summary table for how each is grounded.

## Related Documents

- Architecture: `APP-020` (Configuration Management — the backoff schedule and poll interval both belong here)
- Standards: none yet — a future standard may be warranted once a second real implementation (GHS) exists
- Reference Implementations: none yet — this ADR's approval and GHS's implementation are the prerequisite for a future `reference/messaging` category
- ADRs: `ADR-090` (PostgreSQL as primary datastore — the basis for using it as the outbox mechanism), `ADR-100` (default integration style — explicitly anticipated this ADR for any future async decision, though this ADR governs intra-application async processing, not cross-system integration), `ADR-130` (secret management — provider credentials for the worker's send step follow the existing `LoadCredential=` mechanism, not a new one), `ADR-200` (data-access approach — the outbox table itself is raw SQL + repository pattern, same as everything else)

## Revision History

| Version | Date       | Change                                                     | Author |
| ------- | ---------- | ------------------------------------------------------------ | ------ |
| 0.1     | 2026-08-09 | Initial draft — Proposed, not yet reviewed or approved | Socx   |
| 0.2     | 2026-08-09 | Critical review pass against 18 explicit criteria (consistency, classification, failure-model, retention, observability, provider independence, dead-letter definition, history/outbox relationship). Closed a real correctness gap (crash-recovery reclaims must count as an attempt, or a poison message could retry forever); differentiated `sent`/`failed` retention; specified the `notification_history`↔outbox foreign-key direction; added an explicit Open Questions section. Still Proposed, not approved | Socx   |
| 1.0     | 2026-08-09 | Approved. Retention periods (`sent`, `failed`, `notification_history`) and crash-recovery timeout/backoff schedule confirmed as deliberately deferred to application-level, business/compliance-driven decisions — not platform-wide defaults — each to be presented back to the platform owner for approval when an application implements this pattern, starting with GHS | Socx   |

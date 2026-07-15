---
status: Draft            # Draft | Approved — approval authorises execution; no server change happens before that
date: 2026-07-15
owner: Platform Engineering
---

# Platform Bootstrap Plan

The controlled engineering activity that transforms the fresh Ubuntu droplet (`CS-INF-020`, `ADR-180`) into the baseline SOCX platform on which the reference implementations are verified and the Deliverable 6 build-out proceeds.

This document defines strategy, phases, governance, and verification — **it deliberately contains no installation commands.** Command sets are prepared and reviewed per phase at execution time; executing them against the server requires this plan to be `Approved`.

## Objectives

1. Bring the droplet from fresh-install to a hardened, standards-aligned baseline host.
2. Satisfy every prerequisite in `reference/systemd`'s manifest so Deliverable 6.2 verification can run honestly.
3. Resolve every "Attested / to confirm" row in `CS-INF-020` to Observed, moving that inventory to `Approved`.
4. Capture the entire activity as source material for the first operational runbooks (Deliverable 7) and automation (Deliverable 8).

## Execution Model & Controls

- **Operator-executed.** The platform owner executes on the droplet; each phase's command set is prepared and reviewed before execution. No phase begins until the previous phase's verification has passed and its documentation updates have landed.
- **Everything captured.** A chronological bootstrap log records commands and outputs. Secrets never appear in the log (`SEC-010.5`) — credential *values* are redacted; credential *placement* is recorded.
- **No out-of-phase changes.** Anything discovered mid-phase that isn't in this plan is recorded and scheduled, not improvised (`OPS-020.2` spirit).
- **Standing exceptions unchanged.** The two `GEN-010.9` exceptions recorded in `ADR-180` (`OPS-020` hand-provisioning; `OPS-010.1` single tier) cover this activity; bootstrap neither widens nor closes them. Closure remains with `reference/terraform` (Deliverable 6.6), which must codify what bootstrap builds.

## Success Criteria

Bootstrap is complete when all of the following are true:

1. Hardening is verified by **negative tests**: root SSH login refused, password authentication refused, firewall default-deny with only 22/80/443 open.
2. Every `reference/systemd` prerequisite holds on the host (runtime at absolute path, per-app users, release layout, root-only credentials directory, datastore services).
3. The verification canary survives restart and reboot under the reference units, with credentials loaded and logs in journald.
4. `reference/systemd` has its `verified` field populated (OS, systemd version, method, date) and moves to `Approved`; issue #68 closes.
5. `CS-INF-020` contains no remaining "to confirm" rows and moves to `Approved` (confidence High).
6. The bootstrap log is archived and runbook seeds are extracted (see Runbooks below).
7. No unrecorded deviations occurred.

## Phases

| # | Phase | Depends on | Server changes |
|---|---|---|---|
| B0 | Preflight & fact confirmation | — | None (read-only) |
| B1 | Access hardening | B0 | SSH policy, firewall, auto-updates |
| B2 | System baseline | B1 | Updates, hostname, time sync |
| B3 | Runtime & core services | B2 | Node.js, nginx, PostgreSQL, Redis, certbot installed |
| B4 | Platform scaffolding | B3 | App users, directory layout, credentials directory |
| B5 | Verification canary & 6.2 completion | B4 | Canary release + reference units installed |

### B0 — Preflight & fact confirmation *(read-only)*

- **Objective:** confirm by observation what `CS-INF-020` currently holds by attestation — OS release, systemd version, SSH policy as found, firewall state as found, disk/memory shape.
- **Governed by:** `CS-INF-020` (the rows it marks "to confirm"), `SEC-030` (what good looks like for the next phase).
- **Verification:** facts recorded in the bootstrap log with command output as evidence.
- **Current-State impact:** `CS-INF-020` minor revision — Attested → Observed on hosting/access rows.
- **Rollback:** not applicable — no changes.

### B1 — Access hardening

- **Objective:** the secure-by-default posture before anything else is installed: SSH key-only (root login and password auth disabled), firewall default-deny allowing 22/80/443 only, automatic security updates enabled.
- **Governed by:** `SEC-030` (least privilege, per-person credentials), `SEC-020` (patching), the *secure by default* architecture principle.
- **Verification:** negative tests — a root login attempt is refused, a password auth attempt is refused; firewall status shows exactly the three allowed ports; a fresh key-based admin session succeeds.
- **Current-State impact:** `CS-INF-020` (access + firewall rows), `CS-IAM-010` (infrastructure-access row).
- **Rollback / recovery:** a second SSH session stays open throughout SSH-policy changes (lockout protection); the DigitalOcean recovery console is the break-glass path; a droplet snapshot is taken immediately before this phase.

### B2 — System baseline

- **Objective:** fully patched system, correct hostname, synchronised time.
- **Governed by:** `SEC-020` (dependency/vulnerability management, applied at OS level).
- **Verification:** package state reports current; time sync active; hostname as intended.
- **Current-State impact:** `CS-INF-020` minor revision.
- **Rollback / recovery:** snapshot checkpoint before the phase.

### B3 — Runtime & core services

- **Objective:** install the approved stack the reference implementations assume: Node.js LTS system-wide at a fixed absolute path (`ADR-070`), nginx (`ADR-050`), PostgreSQL 16 (`ADR-090`), Redis (`ADR-090`), certbot (for TLS at 6.3). All from apt-managed sources so `SEC-020` patching covers them.
- **Interim posture, accepted:** nginx serves only its default page until `reference/nginx` lands (6.3); no SOCX configuration is hand-written ahead of it (`OPS-020.3` — configuration starts from the canonical reference, so it *waits* for the canonical reference).
- **Governed by:** `ADR-050`, `ADR-070`, `ADR-090`; `reference/systemd` Prerequisites; `OPS-020` (under exception).
- **Verification:** version checks at absolute paths; postgresql/redis/nginx units active and enabled; local database connectivity confirmed.
- **Current-State impact:** `CS-INF-020` (services, storage rows), `CS-TEC-010` (host-installed technology now Observed).
- **Rollback / recovery:** snapshot checkpoint; package removal is a clean fallback at this stage.

### B4 — Platform scaffolding

- **Objective:** the multi-tenant shape applications land in: one non-login system user per application (`SEC-030` least privilege), the `releases/` + `current` + `shared` layout per application, and the root-only credentials directory (`ADR-130`, `SEC-010`).
- **Deliberately not done here:** application databases and roles (created with deployment, 6.7/6.8); any application code.
- **Governed by:** `SEC-010`/`ADR-130`, `SEC-030`, `reference/systemd` Prerequisites.
- **Verification:** ownership/mode audit — credentials directory root-only, app directories owned by their users, app users have no shell and no password.
- **Current-State impact:** `CS-INF-020`, `CS-IAM-010` (host accounts).
- **Rollback / recovery:** trivially reversible (remove users/directories); snapshot not required.

### B5 — Verification canary & Deliverable 6.2 completion

- **Objective:** prove the platform baseline end-to-end *before* any real application exists, using a minimal hello-world Node service installed as a versioned release under a canary user, with a canary credential file, run under `reference/systemd`'s units.
- **Why a canary:** verifying `app-api.service` needs something to run, but real artefacts need CI/CD (6.4) and deploy glue (6.7). The canary breaks that cycle honestly — and is later reused to verify 6.3's routing and TLS.
- **Scope honesty:** service units are verified fully (unit analysis, start, restart survival, reboot survival, credential loading, journald capture, `SOCX_ENV` present). Backup **timer wiring** is verified against a scratch database with an interim stub; full end-to-end backup verification deliberately waits for the real script (`reference/deployment`, 6.7) and the `OPS-060.3` restore test.
- **Governed by:** `ADR-040`, `ADR-130`; `reference/systemd` Usage steps; `OPS-010.2`.
- **Verification:** the manifest's own re-verification steps, executed and logged.
- **Outcome:** `reference/systemd.verified` populated (`Ubuntu 24.04, systemd <version>, <method>, <date>`) → `Approved`; issue #68 closed; "(currently empty)" annotations for `reference/systemd` removed from citing documents; library ToC updated.
- **Current-State impact:** `CS-INF-020` (canary unit recorded), then its promotion to `Approved` at bootstrap exit.
- **Rollback / recovery:** the canary is disposable by design — unit, user, and release directory removed without trace.

## Rollback & Recovery Strategy (overall)

- **Checkpoint snapshots** before each state-changing phase (B1–B3). Manual snapshots are covered by the standing `OPS-020` exception; 6.6 codifies them.
- **Concurrent-session rule** for all SSH-policy changes; DigitalOcean recovery console as break-glass.
- **The ultimate rollback is re-provisioning.** The greenfield property (`ADR-180`) means the box carries nothing irreplaceable until real data arrives — a bad bootstrap is cheaper to rebuild than to repair. This stops being true the moment production data exists, which is why `OPS-060.1` backups must precede it (`CS-DAT-010`).

## Runbooks To Be Created (Deliverable 7 seeds)

| Runbook | Seeded by | When |
|---|---|---|
| Platform bootstrap & server provisioning | The full B0–B5 log | Immediately after bootstrap — while fresh |
| Droplet access & break-glass recovery | B1 | Immediately after bootstrap |
| TLS issuance & renewal | 6.3 | With `reference/nginx` |
| Deploy & rollback (`OPS-030.3`) | 6.7 | With `reference/deployment` |
| Backup & restore, incl. RPO/RTO (`OPS-060.4`/`.5`) | 6.7 + `OPS-060.3` restore test | With `reference/deployment` |

## After Bootstrap

Bootstrap exits into the Deliverable 6 build-out: 6.3 `reference/nginx` (+ TLS via the canary), 6.4 `reference/github`, 6.5 `reference/security`, 6.6 `reference/terraform` (droplet import — closes both standing exceptions), 6.7 `reference/deployment` (canary retired in favour of the real pipeline), 6.8 `reference/application`, 6.9 `reference/monitoring` — each with the standing loop: verify → Approve → cross-references → Current-State revision.

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-15 | Initial draft for review | Socx   |

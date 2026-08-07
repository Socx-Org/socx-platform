# Operational Runbooks

Step-by-step procedures for operating the platform. Every runbook here answers one question:

> **"What do I actually do when this happens?"**

## Design Philosophy

Runbooks are the *procedure* layer, sitting next to `reference/`'s *configuration* layer. `reference/deployment` demonstrates what `deploy-release.sh` does; a runbook says when to run it, what to check before and after, and what to do if it doesn't go as expected. Neither restates the other — see `reference/README.md`'s own comparison table for the boundary.

Two rules, carried over from `reference/`'s own discipline and applied to procedure instead of configuration:

1. **No untested procedure presented as tested.** A runbook reaches `Approved` only when its procedure has actually been carried out — ideally the exact commands, on the exact real infrastructure they describe — and evidence is recorded in `verified`. A runbook nobody has ever followed is a guess wearing the shape of a fact; `status: Draft` says so honestly.
2. **Every step is the real one, not an idealised one.** Where a real run surfaced a gotcha (a sudo/environment-variable quirk, a required field an API didn't document, a permission grant that wasn't obvious), the runbook says so — that's exactly the knowledge a runbook exists to preserve. Sanitising it back down to the "obvious" version throws away the reason it's worth writing down.

## Lifecycle & Status

```
Draft  →  Approved  →  Deprecated
```

- A new runbook starts `status: Draft`.
- It moves to `status: Approved` only when `verified` records real evidence: what was actually run, against what, and when.
- A runbook is `Deprecated` when the procedure it describes no longer applies (the tooling changed, the failure mode was engineered away) — marked, not deleted, with a pointer to why.

**Ownership:** Platform Engineering. A runbook MUST be re-verified when the reference implementation or standard it operationalises changes underneath it.

## Manifest Convention

Every runbook is a single Markdown file — unlike `reference/`'s categories, a runbook is one procedure, not a set of artefacts, so it doesn't need its own directory of supporting files.

```markdown
---
status: Draft          # Draft | Approved | Deprecated
verified: null         # "<what was run>, <where>, YYYY-MM-DD" — MUST be set before Approved
---

# <category>/<name> — Title

## Purpose & Scope

What this runbook covers, and what it explicitly hands off elsewhere (a
different runbook, a reference implementation, an escalation path).

## Trigger

The concrete signal that means "use this runbook" — an alert firing, a
specific symptom, a scheduled task. Not vague ("something's wrong").

## Prerequisites

Access, credentials, and tools needed before starting.

## Procedure

Numbered steps. Real commands, not paraphrased ones. Gotchas found during
a real run are documented inline, not smoothed away.

## Verification

How to confirm the procedure actually worked — not "it should be fine now."

## Escalation / Rollback

What to do if the procedure doesn't resolve things, or makes them worse.

## Related Documents

- Standards: …
- Reference Implementations: …
- ADRs: …
```

## Categories

| Path | Covers |
|---|---|
| `incident-response/` | Responding to an alert or an observed failure |
| `deployment/` | Shipping a new version, and undoing a bad one |
| `maintenance/` | Routine, planned operational work — rotation, provisioning |

**Deferred, deliberately:** `disaster-recovery/` — restore and full-loss procedures. Writing these now would describe a restore that has never actually been performed (`backup-db.sh` has been run; nothing has ever been restored *from* one) and a droplet-loss scenario no drill has ever exercised. Per this document's own first rule, that's exactly the kind of confident-sounding-but-untested content a runbook must not contain. These become candidates once real evidence exists, not before.

## Table of Contents

| Runbook | Category | Status |
|---|---|---|
| `incident-response/app-down-alert.md` | Incident Response | Approved |
| `deployment/deploy-and-rollback.md` | Deployment | Approved |
| `maintenance/credential-rotation.md` | Maintenance | Approved |
| `maintenance/infrastructure-import.md` | Maintenance | Approved |

The authoritative status for a runbook is its own frontmatter; this table is kept in sync as a convenience index.

## Authoring a New Runbook

1. Confirm the procedure has actually been carried out for real — against the real infrastructure it will describe, not a facsimile — before writing it up. If that hasn't happened yet, the runbook waits, per this document's own first rule.
2. Write it using the skeleton above.
3. Place it in the right category directory (or propose a new category if none fits — don't force a fit).
4. Add a row to this file's Table of Contents.
5. Cross-reference it from whatever it operationalises (a reference implementation's manifest, a standard's `OPS-040.4`-style requirement) and from there back to this document.

---
status: Approved
verified: "On-host, real droplet (prod-lab-01): provisioned /etc/credentials/canary-app (700, root:root), confirmed set-credential.sh's empty-input refusal and its real atomic write (600, root:root), confirmed the written value never appeared in journalctl or shell history, confirmed a real systemd unit's LoadCredential=db_password successfully consumed it at start and the app connected to a real Postgres database with it. Disposable canary-app exercise, torn down after. 2026-08-07"
---

# reference/security — Secret Handling

## Purpose & Scope

How secret material gets onto a host safely, and how local development handles secrets without ever committing one (`ADR-130`, `ADR-110`, `SEC-010`).

**The boundary with `reference/systemd`, stated explicitly:** `reference/systemd` demonstrates *consuming* a credential at the unit level — `LoadCredential=` reading a root-only file at service start — and deliberately defers "how credentials get onto the host" to here. This document is that other half. It does not re-explain `LoadCredential=`; it explains how the file `LoadCredential=` points at actually gets written, safely, in the first place.

**Consuming a credential inside application code** (once `LoadCredential=` has made it available) is demonstrated in two places, not here: `reference/application/apps/api/src/config.ts`'s `readSecret()` for Node/TypeScript services, and `python/credentials.py` (this directory) for a Python worker — `ADR-070`'s bounded, per-project exception to the general stack. Both read `$CREDENTIALS_DIRECTORY/<name>`, falling back to an env var in local dev where `CREDENTIALS_DIRECTORY` is unset. `python/credentials.py` is adapted from a real, tested implementation (`Socx-Org/rms`'s `apps/worker/engine/credentials.py`), found during RMS's Phase 2A discovery to have no documented platform pattern despite GHS/AMS needing the identical thing (`socx-platform#90`).

Explicitly not covered here:

- **Consuming a credential at the systemd-unit level** — `reference/systemd`
- **Actual OIDC client registration or token exchange** — `ADR-120`'s shared identity provider doesn't exist yet as a concrete product; this document covers the at-rest handling pattern a future service-to-service credential would use, not the provider integration itself
- **Incident response procedure for an exposed secret** — `SEC-010.4` requires rotation *and* recording the exposure; the rotation procedure is `docs/runbooks/maintenance/credential-rotation.md`. This document provides the underlying mechanism (`set-credential.sh`), not the operational procedure around it

## Contents

| File | Role |
|---|---|
| `scripts/set-credential.sh` | Safely provisions or rotates a single systemd credential file |
| `env/.env.example` | Local-development secret-hygiene template |
| `python/credentials.py` | Application-side consumption pattern for a Python worker (`ADR-070`'s bounded exception) — populates `os.environ` from `LoadCredential=` files, no-op in local dev |

## Design Decisions

- **`python/credentials.py` populates `os.environ` once, rather than requiring every call site to read a credential explicitly.** The alternative — rewriting each `os.environ.get('X')` call site into an explicit credential read — is more invasive for no real benefit in a codebase that already reads secrets via plain env vars in many places. Populating the environment once, early, lets every existing call site keep working unchanged, in both the systemd (`LoadCredential=`) and local-dev (`.env`) cases. This is a deliberate difference from `reference/application/apps/api/src/config.ts`'s `readSecret()`, which reads explicitly at each config site — both are valid; which one fits depends on how scattered a codebase's existing secret reads already are. Grounded in a real, already-in-production implementation (`Socx-Org/rms`), not a hypothetical.
- **One script for both provisioning and rotation.** Writing a credential file is the same operation whether it's the first write or a replacement — a separate "rotate" script would just duplicate this one. `ADR-110`'s service-to-service credentials use it identically; only the credential *name* differs (a suggested convention: `<callee-app>_client_secret`), not the mechanism.
- **Secret value read from stdin only, never a CLI argument.** A value passed as an argument leaks into shell history and is visible to anyone on the box who can run `ps` while the script executes. Piping avoids both.
- **Never echoed, never logged.** The script prints only the file path and a reminder to restart the consuming service — never the value itself (`SEC-010.5`).
- **Atomic write.** The script writes to a temp file in the *same* directory (guaranteeing the same filesystem, so the final `mv` is atomic) with permissions locked down before any content lands, then renames into place. A reader — or a script that crashes mid-write — can never observe a partially-written credential.
- **`.env.example` is deliberately sparse and placeholder-only.** Its only job is to prove the pattern (safe to commit, real values never checked in); project-specific variables are explicitly left for the consuming project to add, following the same convention.

## Compliance

| Requirement | Satisfied by |
|---|---|
| SEC-010.1 | `.env.example` — every value is a placeholder; nothing here is ever a real secret |
| SEC-010.2 | `.env.example`'s header comment — `.gitignore` entries required from repository creation, not added reactively (see Usage) |
| SEC-010.3 | `set-credential.sh` writes only to `/etc/credentials/<app>/`, the systemd-credentials path — never hardcodes a value anywhere |
| SEC-010.4 | `set-credential.sh` is the rotation mechanism (same command as provisioning); `docs/runbooks/maintenance/credential-rotation.md` is the operational procedure |
| SEC-010.5 | `set-credential.sh`'s stdin-only input and its refusal to ever print or log the value |
| SEC-010.6 | `set-credential.sh` writes with `chmod 600`/`chown root:root`, matching `reference/systemd`'s existing root-only directory pattern |

## Prerequisites

- The target app's credentials directory already exists — `/etc/credentials/<app>/`, mode `700`, root:root (created by `reference/systemd`'s Bootstrap Phase B4 pattern)
- Root or `sudo` access on the host

## Usage

1. **Local development:** copy `env/.env.example` to `.env` in the project root, fill in real local values. Add to `.gitignore`, from repository creation:
   ```
   .env
   .env.*
   !.env.example
   ```
2. **Production credential provisioning:**
   ```
   openssl rand -base64 32 | sudo ./set-credential.sh {{APP_NAME}} jwt_secret
   printf '%s' "$REAL_DB_PASSWORD" | sudo ./set-credential.sh {{APP_NAME}} db_password
   ```
3. **Rotation:** run the exact same command again with the new value. The old value is gone the moment the new file lands (atomic rename) — no separate rotation flag or mode.
4. **After rotating a credential a running service consumes**, restart it so it re-reads via `LoadCredential=`:
   ```
   sudo systemctl restart {{APP_NAME}}-api.service
   ```
5. Re-verify: confirm the file lands with `600`/root:root permissions, confirm the consuming service still starts cleanly after a restart, confirm the value never appears in shell history or `journalctl` output. Record the method and date in this manifest's `verified` field.

## Expected Adaptations

**Consuming projects are expected to customise:**

- `.env.example`'s project-specific variables, following the same placeholder convention
- Which services get restarted after a rotation (varies per app; `set-credential.sh` only writes the file, it doesn't know which services depend on it)

**Must remain unchanged to preserve compliance:**

- Stdin-only secret input — accepting a value as a CLI argument regresses `SEC-010.5`
- The atomic temp-file-then-rename write pattern
- `.env.example` containing only placeholders — a real value here, even a "just for testing" one, is a `SEC-010.1` violation
- File permissions (`600`, root:root) on any written credential

## Related Documents

- Standards: `SEC-010`
- Architecture: `IAM-010` (trust model this realises at the credential-handling layer)
- ADRs: `ADR-130` (systemd credentials), `ADR-110` (service-to-service trust — the credential type this also provisions), `ADR-070` (the Python-worker bounded exception `python/credentials.py` is written for)
- Current-State: none directly
- Runbooks: `docs/runbooks/maintenance/credential-rotation.md` (Approved — covers both routine and exposure-triggered rotation, `SEC-010.4`)
- Reference Implementations: `reference/systemd` (consumes what this provisions at the unit level), `reference/application` (`config.ts`'s `readSecret()` — the Node/TypeScript equivalent of `python/credentials.py`)

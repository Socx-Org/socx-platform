---
id: CS-INF-010
title: Current Infrastructure Inventory
category: Infrastructure
status: Deprecated
gap_status: Diverges
confidence: Medium
owner: Platform Engineering
version: "1.1"
last_reviewed: 2026-07-15
review_cycle: quarterly
related:
  architecture:
    - INF-010
  standards:
    - OPS-010
    - OPS-020
  adrs: []
  reference: []
  runbooks: []
supersedes: []
superseded_by: CS-INF-020
---
# CS-INF-010 — Current Infrastructure Inventory

> **Deprecated (2026-07-15).** The droplet this inventory describes was decommissioned per `ADR-180`; its successor is inventoried in `CS-INF-020`. This document is retained unchanged as the historical record — its findings (the `nvm` startup fragility, the monolithic `apps.conf`, the empty redesign scaffolds) are cited as evidence by `ADR-040`, `ADR-050`, `ADR-130`, `ADR-180`, and `reference/systemd`.

## Scope

The actual hosting, network, and configuration facts for the platform's infrastructure, as observed or documented — concrete detail belongs here, unlike `INF-010`, which must stay conceptual. Covers DNS, TLS certificates, reverse proxy, firewall, system services, scheduled jobs, and storage.

## Method

Read from `platform-infra`'s own `deployment-architecture.md` (a 2,889-line infrastructure audit and redesign document, dated 3 July 2026) and the actual file contents of its `nginx/`, `systemd/`, and `scripts/` directories. **No SSH or other direct access to the production droplet was available** — nothing below was confirmed by connecting to a live server. `deployment-architecture.md` itself is explicitly a **redesign proposal**, produced from an audit of an "existing architecture" it repeatedly critiques; facts attributed to "existing architecture" in that document are treated as Inferred (a detailed, specific second-hand audit, not a first-hand observation), while facts about the *new* `platform-infra` repository's own files (which I read directly) are Observed.

## Inventory

**Headline finding:** `platform-infra`'s entire `nginx/sites/*.conf` set and `systemd/services/*.service` set — one file per application, matching the redesign's own naming convention — are **all present but literally empty (0 bytes)**, as are all ten of its `scripts/*.sh` files. The redesign is fully planned (directory structure, naming, a 2,889-line rationale document) but **not yet implemented**. The "existing architecture" described critically in that same document is, by elimination, what is presumed to actually be running today.

### DNS

| Fact                    | Value                                                                   | Evidence                                                                              |
| ----------------------- | ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| Domain                  | `socx.org.uk` and four subdomains: `www`, `ghs`, `rms`, `ams` | Inferred — subdomain names taken from`platform-infra`'s nginx `sites/` filenames |
| Records, TTL, registrar | Unknown                                                                 | No DNS zone file or registrar reference found                                         |

### TLS Certificates

| Fact                          | Value                                                                                                        | Evidence                                                                                       |
| ----------------------------- | ------------------------------------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------- |
| Issuer (intended)             | Let's Encrypt                                                                                                | Inferred — stated in`deployment-architecture.md`'s architecture diagram                     |
| Renewal mechanism             | A`cert-check.sh` script and a `cert-check.timer`/`cert-check.service` pair exist in `platform-infra` | Observed (files exist);**content is empty** — automation is scaffolded, not implemented |
| Actual certificate(s), expiry | Unknown                                                                                                      | No access to the live server or certificate store                                              |

### Reverse Proxy

| Fact                                   | Value                                                                                                                                                                                                  | Evidence                                                                                          |
| -------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------- |
| Software                               | nginx                                                                                                                                                                                                  | Observed (directory structure, template files)                                                    |
| Intended pattern                       | One config file per application (avoids one app's syntax error taking down all four)                                                                                                                   | Observed —`deployment-architecture.md` "Principle 3"                                           |
| Actual current pattern (per the audit) | A**single monolithic `apps.conf`** serving all four applications today                                                                                                                         | Inferred from the audit's explicit critique of "the existing architecture"                        |
| Known defect (per the audit)           | Nginx currently strips the`/api/` prefix before proxying to Express; this caused a **confirmed past incident**: "complete RMS API failure" (Express expects `/api/v1/*`, receives `/v1/*`) | Inferred — described as a specific, already-occurred failure in the audit, not a hypothetical    |
| Actual live config content             | Unknown                                                                                                                                                                                                | The new per-app config files are empty; the old monolithic config was not located on this machine |

### Firewall

| Fact                     | Value            | Evidence                                                                   |
| ------------------------ | ---------------- | -------------------------------------------------------------------------- |
| Tool                     | UFW              | Inferred — stated in`deployment-architecture.md`'s architecture diagram |
| Allowed ports (intended) | 22, 80, 443 only | Inferred — same diagram                                                   |
| Actual current ruleset   | Unknown          | No access to the live server                                               |

### System Services

| Fact                          | Value                                                                                                                                                                                                                                                                                                                                                                                                                                                           | Evidence                                                             |
| ----------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| Intended services             | One`-api` and one `-worker` systemd unit per app (`www`, `ghs`, `rms`, `ams`), plus `rms-worker-py` for RMS's Python worker                                                                                                                                                                                                                                                                                                                       | Observed — filenames present in`platform-infra/systemd/services/` |
| Actual unit file content      | Unknown — all files present are empty                                                                                                                                                                                                                                                                                                                                                                                                                          | Observed (emptiness)                                                 |
| Known defects (per the audit) | Three service definitions reference scripts that**do not exist**: `npm run start` for RMS web, `python -m worker` for RMS worker, `npm run worker` for `www` worker; `ExecStart` currently sources `nvm` via `bash -lc`, which fails if `$HOME` or the Node version don't resolve correctly in the systemd context; deploy scripts use `\|\| true` after `systemctl restart`, so a service that fails to start can still report success | Inferred — specific, itemized critique in the audit                 |

### Scheduled Jobs

| Fact                             | Value                                                                                                                | Evidence                                                                                   |
| -------------------------------- | -------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------ |
| Intended jobs                    | `db-backup-daily@.timer`, `db-backup-hourly@.timer` (with matching `db-backup@.service`), `cert-check.timer` | Observed — filenames present in`platform-infra/systemd/backup/` and `.../monitoring/` |
| Actual schedule, last-run status | Unknown — all timer/service files present are empty                                                                 | Observed (emptiness)                                                                       |

### Storage

| Fact                                      | Value                                                                                                                          | Evidence                     |
| ----------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------ | ---------------------------- |
| Database engine                           | PostgreSQL (per`deployment-architecture.md`'s diagram: `rms_db`, `ghs_db`)                                               | Inferred                     |
| Cache                                     | Redis at`127.0.0.1:6379`                                                                                                     | Inferred — same diagram     |
| Disk capacity, mount points, actual usage | Unknown                                                                                                                        | No access to the live server |
| Application file storage                  | `ams` has an `uploads/documents` directory in its own repository (local dev artifact); production storage location Unknown | Observed (local dev only)    |

## Gap vs. Target Architecture

| Aspect            | Current State                                                                                               | Target (`INF-010`)                                                    | Difference                                                                                                                                                              | Impact                                                                                                                                                                       |
| ----------------- | ----------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Shared edge       | A single droplet's nginx does front all four apps today, consistent in shape with`INF-010`'s diagram      | Single shared nginx edge → systemd-managed processes                   | Shape matches; but today's nginx is one monolithic config (not "one failure domain per app"), and today's systemd units are`nvm`-wrapped rather than direct-execution | `INF-010` is conceptually correct but the current implementation has a known single-point-of-failure (one config, one bad app breaks all four) and known startup fragility |
| Environment tiers | No evidence of any non-production environment — one droplet appears to serve everything                    | `OPS-010` requires at least two tiers (non-production and production) | No non-production tier found                                                                                                                                            | This is a live standards gap, not just an architecture gap: if accurate,`OPS-010.1` is not currently satisfied anywhere on the platform                                    |
| Redesign rollout  | Fully scaffolded (structure, naming, extensive rationale) but core config/scripts are empty — not yet live | N/A —`INF-010` doesn't track rollout status                          | —                                                                                                                                                                      | The redesign closing today's gaps is written but not executed; until it is, the known defects above remain live risks                                                        |

## Related Documents

- Architecture: `INF-010`
- Standards: `OPS-010`, `OPS-020`
- ADRs: none yet
- Reference Implementations: none in `reference/` — `platform-infra`'s own (currently empty) config files would be the natural candidate once populated
- Runbooks: none in this repository; `platform-infra/docs/runbook.md` exists but is currently empty

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-13 | Initial draft | Socx   |
| 1.0     | 2026-07-13 | Approved      | Socx   |
| 1.1     | 2026-07-15 | Deprecated — described droplet decommissioned (ADR-180); superseded by CS-INF-020 | Socx   |

---
id: REP-010
title: Repository Inventory
category: Repository
status: Approved
gap_status: N/A — no architecture counterpart
confidence: High
owner: Platform Engineering
version: "1.0"
last_reviewed: 2026-07-13
review_cycle: quarterly
related:
  architecture: []
  standards:
    - ENG-050
    - ENG-060
  adrs: []
  reference: []
  runbooks: []
supersedes: []
superseded_by: null
---
# REP-010 — Repository Inventory

## Scope

Which repositories actually exist for the SOCX platform, what each is for, where it deploys, and its lifecycle status. No architecture counterpart — this is a stand-alone engineering-governance inventory (per `docs/architecture/README.md`'s numbering scheme note).

## Method

Direct filesystem and `git` inspection performed in this session: `git remote -v`, `git log`, `git branch --show-current`, and directory listings against repositories found on the local machine outside this repository's own directory. No SSH access to any production server was available or used.

## Inventory

**Headline finding:** the platform is mid-migration between two GitHub organizations. `github.com/socx/*` (lowercase) holds the real, actively developed repositories with substantial commit history. `github.com/Socx-Org/*` (matching this repository's own home) holds newly created repositories, most still empty placeholders — the migration target, not yet populated.

| Repository                                              | Purpose (as stated by the repo itself)                                                     | Deployment target                         | Default branch                                                                                | Owner                                | Lifecycle status                                                                                                                                                                                        | Evidence |
| ------------------------------------------------------- | ------------------------------------------------------------------------------------------ | ----------------------------------------- | --------------------------------------------------------------------------------------------- | ------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------- |
| `socx-platform`                                       | Engineering source of truth (this repository)                                              | N/A — no application code                | `main`                                                                                      | Platform Engineering                 | Active                                                                                                                                                                                                  | Observed |
| `platform-infra`                                      | Shared reverse-proxy/hosting infrastructure for all applications                           | Single DigitalOcean droplet, Ubuntu 24.04 | `main`                                                                                      | Unknown — no owner recorded in-repo | Active — mid-redesign (see`CS-INF-010`)                                                                                                                                                              | Observed |
| `socx-org-uk`                                         | Org website — served as`www.socx.org.uk`; Express API + React/Vite web + worker         | Same shared droplet                       | `main` (new org copy); `central-infra` (prior org copy — non-default branch checked out) | Unknown                              | Active                                                                                                                                                                                                  | Observed |
| `ghs` (repo name: `golf-handicap-system`)           | Golf handicap tracking system — served as`ghs.socx.org.uk`                              | Same shared droplet                       | `main`                                                                                      | Unknown                              | Active —**not yet migrated** to the `Socx-Org` GitHub organization (still only a 1-commit placeholder there)                                                                                   | Observed |
| `rms` (repo self-titled "Reminder Management System") | A reminder-centred notification platform — served as`rms.socx.org.uk`                   | Same shared droplet                       | `main`                                                                                      | Unknown                              | Active —**not yet migrated** to `Socx-Org` (placeholder only there)                                                                                                                            | Observed |
| `ams` (repo name: `asset-manager`)                  | "A full-stack, production-grade asset management platform" — served as`ams.socx.org.uk` | Same shared droplet                       | `main`                                                                                      | Unknown                              | Active —**not yet migrated** to `Socx-Org` (placeholder only there); **not present anywhere in this repository's charter, README, or Related Repositories list prior to this inventory** | Observed |

**Important discrepancy:** this repository's project charter and README list only `socx-org-uk`, `ghs`, and `rms` as related repositories. The actual deployed footprint (per `platform-infra`'s own nginx/systemd naming) includes a fourth application, `ams`, plus the shared `platform-infra` repository itself. `CS-DOM-010` and `CS-CTX-010` reflect this discovered footprint. Updating the charter's repository list is recommended but out of scope for this inventory.

## Related Documents

- Architecture: none — no counterpart
- Standards: `ENG-050` (repository structure), `ENG-060` (naming conventions) — neither has been checked for compliance against these real repositories yet
- ADRs: none yet
- Reference Implementations: none
- Runbooks: none in this repository; `platform-infra` itself contains a `docs/runbook.md` (currently empty) and `ghs` contains `product-management/deployment-digitalocean-runbook.md` (not reviewed in depth for this inventory)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-13 | Initial draft | Socx   |
| 1.0     | 2026-07-13 | Approved      | Socx   |

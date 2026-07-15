---
id: CS-INF-020
title: Current Infrastructure Inventory
category: Infrastructure
status: Draft
gap_status: Diverges
confidence: Medium
owner: Platform Engineering
version: "0.1"
last_reviewed: 2026-07-15
review_cycle: quarterly
related:
  architecture:
    - INF-010
  standards:
    - OPS-010
    - OPS-020
  adrs:
    - ADR-180
    - ADR-040
  reference: []
  runbooks: []
supersedes:
  - CS-INF-010
superseded_by: null
---
# CS-INF-020 — Current Infrastructure Inventory

## Scope

The actual hosting, network, and configuration facts for the platform's infrastructure as of the greenfield rebuild baseline (`ADR-180`). Supersedes `CS-INF-010`, which described the original droplet, decommissioned in July 2026 and retained as the historical record.

## Method

Two sources, dated 2026-07-15: **(a)** provisioning attestation from the platform owner (droplet specification, access model, legacy-data disposition); **(b)** direct DNS observation (`dig` A-record lookups performed from an external network). **No SSH inspection of the droplet has been performed yet** — rows sourced only from attestation are marked accordingly and should be confirmed during Platform Bootstrap, at which point this inventory is revised.

## Inventory

**Headline:** a fresh, empty host. One newly provisioned DigitalOcean droplet running Ubuntu 24.04 LTS, with DNS already pointing at it and **nothing deployed** — no applications, no reverse proxy, no databases, no TLS, no scheduled jobs, no backups.

### Hosting

| Fact | Value | Evidence |
|---|---|---|
| Provider / shape | DigitalOcean, single droplet | Attested |
| Operating system | Ubuntu 24.04 LTS (systemd 255 — meets `reference/systemd`'s ≥ 245 prerequisite) | Attested (OS); Inferred (systemd version, from the 24.04 default) |
| Environment tier | Single box serving as production, interim — no non-production tier (`OPS-010.1` exception recorded in `ADR-180`) | Attested |
| Provisioning method | Manual (`OPS-020` exception recorded in `ADR-180`; closed when `reference/terraform` imports the droplet) | Attested |

### DNS

| Fact | Value | Evidence |
|---|---|---|
| A records | `socx.org.uk`, `ghs.`, `rms.`, `ams.` → `209.97.135.128`; `www` → CNAME → apex | Observed (dig, 2026-07-15) |
| Registrar, TTLs | Unknown | Not yet inspected |

### TLS Certificates

None issued for the new host. — Attested

### Reverse Proxy

None installed. Target: nginx per `ADR-050` / `reference/nginx`. — Attested

### System Services

Stock Ubuntu only; no application units. Target: direct-execution units per `reference/systemd`. — Attested

### Scheduled Jobs

None (accordingly, **no backups run** — nothing exists yet to back up). — Attested

### Storage

| Fact | Value | Evidence |
|---|---|---|
| Databases | None installed | Attested |
| Application data | None | Attested |
| Legacy data | The retired droplet's data was **not migrated, snapshotted, or exported** — it held no production data worth keeping (test/development only), per `ADR-180` | Attested |

### Access

| Fact | Value | Evidence |
|---|---|---|
| SSH | One non-root admin user with SSH-key authentication | Attested |
| Root login / password auth / firewall state | Unknown — to confirm and harden during Platform Bootstrap (`SEC-030`) | Not yet inspected |

## Gap vs. Target Architecture

| Aspect | Current State | Target (`INF-010`) | Difference | Impact |
|---|---|---|---|---|
| Everything above the OS | Empty host | Shared nginx edge → systemd-managed processes, provisioned as code, two environment tiers | The entire target topology is unbuilt | Expected and intentional (`ADR-180`) — this document is the rebuild's measurement baseline; the gap closes milestone-by-milestone through the Deliverable 6 build-out |
| Governance exceptions | Hand-provisioned; single tier | `OPS-020`; `OPS-010.1` | Two open `GEN-010.9` exceptions | Time-boxed, tracked in `ADR-180`, closed by `reference/terraform` |

## Related Documents

- Architecture: `INF-010`
- Standards: `OPS-010`, `OPS-020` (both under recorded exception)
- ADRs: `ADR-180` (the transition this baselines), `ADR-040`
- Reference Implementations: `reference/systemd` (verification host prerequisite met), `reference/nginx`, `reference/terraform` (all pending)
- Runbooks: none yet
- Current-State: supersedes `CS-INF-010` (historical record of the retired droplet)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-15 | Initial draft — clean-slate baseline after greenfield rebuild decision (ADR-180) | Socx   |

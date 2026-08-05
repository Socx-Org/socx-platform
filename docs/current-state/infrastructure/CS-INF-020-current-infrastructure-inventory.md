---
id: CS-INF-020
title: Current Infrastructure Inventory
category: Infrastructure
status: Draft
gap_status: Diverges
confidence: Medium
owner: Platform Engineering
version: "0.3"
last_reviewed: 2026-08-06
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

Four sources: **(a)** provisioning attestation from the platform owner, dated 2026-07-15 (droplet specification, access model, legacy-data disposition); **(b)** direct DNS observation (`dig` A-record lookups performed from an external network), dated 2026-07-15; **(c)** a second provisioning attestation, dated 2026-08-06, recording that the droplet was rebuilt a second time (Ubuntu 26.04 LTS, same reserved IP, DNS managed via Cloudflare and left unchanged) before any bootstrap execution occurred; **(d)** direct SSH inspection via Platform Bootstrap Phase B0, dated 2026-08-05 (the droplet's own clock reading at command time), the first real observation of the live host. Rows sourced only from attestation and not yet reached by B0 are marked accordingly.

## Inventory

**Headline:** a fresh, empty host, now confirmed by direct inspection (Bootstrap Phase B0). One DigitalOcean droplet running **Ubuntu 26.04 LTS** (rebuilt 2026-08-06, superseding an initial 24.04 LTS provisioning that was never bootstrapped), with DNS already pointing at it and **nothing deployed** — no applications, no reverse proxy, no databases, no TLS, no scheduled jobs, no backups. Two access findings surfaced that were not previously attested: root SSH login is currently permitted by key, and two human accounts exist rather than one — see Access below.

### Hosting

| Fact | Value | Evidence |
|---|---|---|
| Provider / shape | DigitalOcean, single droplet (same reserved IP retained across the 2026-08-06 rebuild); kernel `7.0.0-27-generic`, KVM virtualisation | Attested (provider); Observed (kernel/virt, B0) |
| Operating system | Ubuntu 26.04 LTS ("resolute"); **systemd 259 (259.5-0ubuntu3) confirmed** — clears `reference/systemd`'s ≥ 245 floor comfortably | Observed (B0) |
| Hostname / networking | Static hostname `prod-lab-01`. Public `209.97.135.128`; private networking `10.16.0.5`, `10.106.0.2`; IPv6 `2a03:b0c0:1:e0:0:1:6ca0:2001` | Observed (B0) |
| Resources | 1 vCPU, ~956 MiB RAM, 24 GB disk (2.2 GB used) — small; worth watching once Node + PostgreSQL + Redis + nginx are all installed (Bootstrap Phase B3) | Observed (B0) |
| Environment tier | Single box serving as production, interim — no non-production tier (`OPS-010.1` exception recorded in `ADR-180`) | Attested |
| Provisioning method | Manual (`OPS-020` exception recorded in `ADR-180`; closed when `reference/terraform` imports the droplet) | Attested |
| Time sync | NTP active, clock synchronised (`Etc/UTC`) | Observed (B0) |
| Pending OS updates | 6 packages pending; `unattended-upgrades` 2.12ubuntu9 present — activation to be confirmed in Bootstrap Phase B2 | Observed (B0) |

### DNS

| Fact | Value | Evidence |
|---|---|---|
| A records | `socx.org.uk`, `ghs.`, `rms.`, `ams.` → `209.97.135.128`; `www` → CNAME → apex | Observed (dig, 2026-07-15) |
| DNS management | Cloudflare. The 2026-08-06 droplet rebuild retained the same IP, so no repointing was required or performed | Attested |
| Registrar, TTLs, proxy status (orange-cloud vs DNS-only) | Unknown | Not yet inspected |

### TLS Certificates

None issued for the new host. — Attested

### Reverse Proxy

None installed. Target: nginx per `ADR-050` / `reference/nginx`. — Attested

### System Services

Stock Ubuntu only; no application units. Only `sshd` (ports 22, IPv4+IPv6) and loopback-only `systemd-resolved` (`127.0.0.53`/`127.0.0.54`, DNS stub resolver) are listening — nothing externally reachable beyond SSH. Target: direct-execution units per `reference/systemd`. — Observed (B0)

### Scheduled Jobs

None (accordingly, **no backups run** — nothing exists yet to back up). — Attested

### Storage

| Fact | Value | Evidence |
|---|---|---|
| Databases | None installed — confirmed absent (`node`, `npm`, `psql`, `redis-server`, `nginx`, `certbot`, `terraform` all checked, none present) | Observed (B0) |
| Application data | None | Attested |
| Legacy data | The retired droplet's data was **not migrated, snapshotted, or exported** — it held no production data worth keeping (test/development only), per `ADR-180` | Attested |

### Access

**Corrects the prior attestation of "one non-root admin user."** B0 found **two** human accounts:

| Fact | Value | Evidence |
|---|---|---|
| Human accounts | `ubuntu` (UID 1000) — DigitalOcean's default cloud-init account, not explicitly disabled; `deploy` (UID 1001) — created by a local, untracked automation script (`create-deploy-user-on-droplet.sh`, outside this repository), granted sudo, with root's `authorized_keys` copied onto it | Observed (B0) |
| Root account | Password locked (`L`) — password-based root login is impossible | Observed (B0) |
| SSH policy | `PermitRootLogin yes`, `PasswordAuthentication no`, `PubkeyAuthentication yes`. **Root SSH login via key is currently permitted** — the one substantive hardening gap this inventory identifies (root's key is live because `deploy`'s key was copied from it) | Observed (B0) |
| Firewall | UFW `inactive` | Observed (B0) |
| SSH host keys | Changed with the 2026-08-06 rebuild — any `known_hosts` entry cached for this IP from the first (24.04) provisioning is now stale and will trigger a host-key-mismatch warning on next reconnect; expected, not a compromise indicator | Attested |

**Remediation (`SEC-030`), planned for Bootstrap Phase B1:** disable root SSH login entirely (`PermitRootLogin no`); decide the fate of the unused `ubuntu` account (recommended: disable rather than delete); enable UFW (22/80/443 only); confirm `unattended-upgrades` is active.

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
- Runbooks: none yet — the B1 remediation (root login, `ubuntu` account, firewall) is a candidate first entry for the access/break-glass runbook
- Current-State: supersedes `CS-INF-010` (historical record of the retired droplet)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-15 | Initial draft — clean-slate baseline after greenfield rebuild decision (ADR-180) | Socx   |
| 0.2     | 2026-08-06 | Droplet rebuilt a second time before bootstrap execution (Ubuntu 24.04 → 26.04 LTS, same reserved IP, no DNS repoint needed); added Cloudflare as confirmed DNS layer; noted SSH host-key change | Socx   |
| 0.3     | 2026-08-06 | Bootstrap Phase B0 executed: systemd/OS/network/resource facts moved from Attested to Observed; corrected "one admin user" to two (ubuntu, deploy); recorded root-SSH-permitted finding for B1 remediation | Socx   |

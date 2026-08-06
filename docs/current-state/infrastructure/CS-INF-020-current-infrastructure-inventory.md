---
id: CS-INF-020
title: Current Infrastructure Inventory
category: Infrastructure
status: Draft
gap_status: Diverges
confidence: Medium
owner: Platform Engineering
version: "0.7"
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

**Headline:** a fresh, empty host, now confirmed by direct inspection (Bootstrap Phases B0–B1). One DigitalOcean droplet running **Ubuntu 26.04 LTS** (rebuilt 2026-08-06, superseding an initial 24.04 LTS provisioning that was never bootstrapped), with DNS already pointing at it and **nothing deployed** — no applications, no reverse proxy, no databases, no TLS, no scheduled jobs, no backups. Access hardening is largely complete: `deploy` has verified passwordless sudo, the unused `ubuntu` account is locked out, and the firewall is active. **One item remains a standing, owner-directed exception: root SSH login by key remains permitted** — see Access below.

### Hosting

| Fact | Value | Evidence |
|---|---|---|
| Provider / shape | DigitalOcean, single droplet (same reserved IP retained across the 2026-08-06 rebuild); kernel `7.0.0-29-generic` (upgraded from `7.0.0-27-generic` in Bootstrap Phase B2, confirmed running post-reboot), KVM virtualisation | Observed (B0 initial; B2 post-reboot) |
| Operating system | Ubuntu 26.04 LTS ("resolute"); **systemd 259 (259.5-0ubuntu3) confirmed** — clears `reference/systemd`'s ≥ 245 floor comfortably | Observed (B0) |
| Hostname / networking | Static hostname `prod-lab-01`. Public `209.97.135.128`; private networking `10.16.0.5`, `10.106.0.2`; IPv6 `2a03:b0c0:1:e0:0:1:6ca0:2001` | Observed (B0) |
| Resources | 1 vCPU, ~956 MiB RAM, 24 GB disk (2.2 GB used) — small; worth watching once Node + PostgreSQL + Redis + nginx are all installed (Bootstrap Phase B3) | Observed (B0) |
| Environment tier | Single box serving as production, interim — no non-production tier (`OPS-010.1` exception recorded in `ADR-180`) | Attested |
| Provisioning method | Manual (`OPS-020` exception recorded in `ADR-180`; closed when `reference/terraform` imports the droplet) | Attested |
| Time sync | NTP active, clock synchronised (`Etc/UTC`) | Observed (B0) |
| Pending OS updates | **Applied in Bootstrap Phase B2** (`apt-get upgrade` + `dist-upgrade`, including the kernel bump above). ~20 packages remain upgradable — confirmed to be Ubuntu's phased-rollout holdouts (the systemd package family, all pinned at an identical version bump, plus a handful of others), not a gap; they apply automatically via `unattended-upgrades` (2.12ubuntu9, confirmed active: `APT::Periodic::Update-Package-Lists` and `Unattended-Upgrade` both `"1"`) as Canonical's rollout reaches this host. Not something to force manually — doing so would defeat phasing's safety purpose | Observed (B2, 2026-08-06) |

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

**Corrects the prior attestation of "one non-root admin user."** B0 found **two** human accounts; B1 has since locked one of them out:

| Fact | Value | Evidence |
|---|---|---|
| Human accounts | `ubuntu` (UID 1000) — DigitalOcean's default cloud-init account. **Now locked**: password locked (`L`), shell set to `/usr/sbin/nologin`; no `authorized_keys` file was found for it (nothing to neutralize). `deploy` (UID 1001) — created by a local, untracked automation script (`create-deploy-user-on-droplet.sh`, outside this repository), sudo-enabled, with root's `authorized_keys` originally copied onto it | Observed (B0 discovery; B1 lockout applied and verified) |
| Root account | Password locked (`L`) — password-based root login is impossible | Observed (B0) |
| SSH policy | `PermitRootLogin yes`, `PasswordAuthentication no`, `PubkeyAuthentication yes`. **Root SSH login via key remains permitted** — a standing, owner-directed exception (see below), not an oversight | Observed (B0) |
| Firewall | UFW **active**: default deny (incoming), allow (outgoing); exactly `22/tcp`, `80/tcp`, `443/tcp` allowed (IPv4 + IPv6) | Observed (B1, 2026-08-06) |
| SSH host keys | Changed with the 2026-08-06 rebuild — any `known_hosts` entry cached for this IP from the first (24.04) provisioning is now stale and will trigger a host-key-mismatch warning on next reconnect; expected, not a compromise indicator | Attested |
| `deploy` sudo capability | **Fixed and verified.** A scoped, `visudo`-validated `/etc/sudoers.d/deploy` (`NOPASSWD:ALL`) was installed; `ssh deploy@<host> 'sudo whoami'` from a separate session returned `root` with no password prompt. `deploy` is now a fully functional administrative account independent of root | Observed (verified by platform owner, 2026-08-06) |

**Remediation status:** steps (1) `deploy` passwordless sudo, (3) `ubuntu` lockout, (4) firewall, and (5) `unattended-upgrades` confirmation are **all done and verified** (2026-08-06), and — following the reboot in Bootstrap Phase B2 — **all four are additionally confirmed to survive a reboot**, not just present in the live session that created them: `deploy` sudo still passwordless, firewall still active with the same rules, `ubuntu` still locked, post-reboot. Step (2) — disabling root SSH login — is a **standing exception at the platform owner's explicit, reiterated direction**: proceed with the rest of B1, but leave root login untouched. This is not a formal `GEN-010.9` standards exception (`SEC-030` has no numbered requirement mandating root-login be disabled specifically) — it is a deliberate, indefinite operational choice, recorded here so it is never mistaken for an oversight. **Residual risk while it stands:** root SSH login by key remains a second, parallel path to full privilege alongside the now-verified `deploy` account — a wider access surface than `SEC-030.1`/`.5` least-privilege would otherwise favour. No resumption is scheduled; revisit at the owner's discretion.

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
- Runbooks: none yet — the B1 access-hardening sequence (sudo fix, account lockout, firewall) is a candidate first entry for the access/break-glass runbook
- Current-State: supersedes `CS-INF-010` (historical record of the retired droplet)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-15 | Initial draft — clean-slate baseline after greenfield rebuild decision (ADR-180) | Socx   |
| 0.2     | 2026-08-06 | Droplet rebuilt a second time before bootstrap execution (Ubuntu 24.04 → 26.04 LTS, same reserved IP, no DNS repoint needed); added Cloudflare as confirmed DNS layer; noted SSH host-key change | Socx   |
| 0.3     | 2026-08-06 | Bootstrap Phase B0 executed: systemd/OS/network/resource facts moved from Attested to Observed; corrected "one admin user" to two (ubuntu, deploy); recorded root-SSH-permitted finding for B1 remediation | Socx   |
| 0.4     | 2026-08-06 | Recorded that `deploy`'s sudo is currently non-functional (disabled-password account, password-requiring sudo policy); reordered B1 remediation to fix and verify this before disabling root login | Socx   |
| 0.5     | 2026-08-06 | `deploy` passwordless sudo fixed and verified; remaining B1 hardening (root login, ubuntu account, firewall, unattended-upgrades) explicitly postponed at owner's request — recorded as a deferred task with residual risk noted, not a formal standards exception | Socx   |
| 0.6     | 2026-08-06 | Bootstrap Phase B1 (continued): `ubuntu` locked out, firewall active (22/80/443 only), `unattended-upgrades` confirmed active. Root-login-permitted reframed from a temporary pause to a standing, owner-directed exception with no scheduled resumption | Socx   |
| 0.7     | 2026-08-06 | Bootstrap Phase B2 executed: OS packages patched, kernel upgraded to `7.0.0-29-generic` and confirmed running post-reboot; remaining ~20 packages confirmed as phased-rollout holdouts, not a gap; B1 hardening (sudo, firewall, ubuntu lockout) confirmed to survive the reboot | Socx   |

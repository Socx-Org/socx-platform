---
id: CS-INF-020
title: Current Infrastructure Inventory
category: Infrastructure
status: Draft
gap_status: Diverges
confidence: Medium
owner: Platform Engineering
version: "0.9"
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

**Headline:** the runtime substrate is installed (B0–B3) and the platform scaffolding is now in place (B4): a dedicated system user, `/opt/<app>/{releases,shared}` directory layout, and a root-only credentials directory exist for each of the four systems (`socx-org-uk`, `ghs`, `rms`, `ams`, per `CS-DOM-010`) on the **Ubuntu 26.04 LTS** droplet (rebuilt 2026-08-06, superseding an initial 24.04 LTS provisioning that was never bootstrapped). **Still nothing application-level deployed** — no application code, no SOCX-specific nginx config, no databases created, no TLS certificate issued, no scheduled jobs, no backups. Access hardening is largely complete: `deploy` has verified passwordless sudo, the unused `ubuntu` account is locked out, and the firewall is active. **One item remains a standing, owner-directed exception: root SSH login by key remains permitted** — see Access below.

### Hosting

| Fact | Value | Evidence |
|---|---|---|
| Provider / shape | DigitalOcean, single droplet (same reserved IP retained across the 2026-08-06 rebuild); kernel `7.0.0-29-generic` (upgraded from `7.0.0-27-generic` in Bootstrap Phase B2, confirmed running post-reboot), KVM virtualisation | Observed (B0 initial; B2 post-reboot) |
| Operating system | Ubuntu 26.04 LTS ("resolute"); **systemd 259 (259.5-0ubuntu3) confirmed** — clears `reference/systemd`'s ≥ 245 floor comfortably | Observed (B0) |
| Hostname / networking | Static hostname `prod-lab-01`. Public `209.97.135.128`; private networking `10.16.0.5`, `10.106.0.2`; IPv6 `2a03:b0c0:1:e0:0:1:6ca0:2001` | Observed (B0) |
| Resources | 1 vCPU, ~956 MiB RAM, 24 GB disk (2.2 GB used, pre-install) — small. Node, PostgreSQL, Redis, and nginx are now all installed (Bootstrap Phase B3); disk/memory headroom has not yet been re-measured post-install — worth checking before B4 scaffolding or B8 application deployment add further load | Observed (B0 baseline; B3 install not yet re-measured) |
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

`certbot` 4.0.0 and the `python3-certbot-nginx` plugin are installed (Bootstrap Phase B3), with `certbot.timer` enabled for renewal — but **no certificate has been issued yet**. Issuance is deliberately deferred to Bootstrap Phase 6.3, once real site configuration exists for it to attach to. — Observed (B3, 2026-08-06)

### Reverse Proxy

**nginx installed** (Bootstrap Phase B3), `active`, `enabled`, serving only its **default page** on port 80 (`HTTP/1.1 200 OK` confirmed) — no SOCX site configuration yet, per the Bootstrap Plan's deliberate sequencing (config starts from the canonical `reference/nginx`, which lands in 6.3, not hand-written ahead of it — `OPS-020.3`). — Observed (B3, 2026-08-06)

### System Services

`sshd` (ports 22, IPv4+IPv6), loopback-only `systemd-resolved`, plus (as of B3) **nginx** (port 80, externally reachable — allowed by the firewall), **PostgreSQL 16** and **Redis 8.0.5** (both local-only by default, not exposed through the firewall), and **certbot.timer**. Also present, **pre-existing and vendor-provided, not installed by this bootstrap**: DigitalOcean's **`droplet-agent`** (1.4.0, `active`/`running`) and its `droplet-agent-update.timer` (hourly) — discovered while inspecting `/opt/` during B4; confirmed via `dpkg -l` and `systemctl`, not assumed. No application units yet — target remains direct-execution units per `reference/systemd`, to be added in B5. — Observed (B0 baseline; B3 additions; B4 discovery)

### Scheduled Jobs

None application-level (accordingly, **no backups run** — nothing exists yet to back up). `droplet-agent-update.timer` (hourly, DigitalOcean-provided) is the only timer present. — Observed (B4)

### Application Scaffolding

Created in Bootstrap Phase B4, for each of the four systems (`socx-org-uk`, `ghs`, `rms`, `ams`, per `CS-DOM-010`):

| Fact | Value | Evidence |
|---|---|---|
| System users | One dedicated, non-interactive account per app (system UIDs 106–109), home `/nonexistent`, shell `/usr/sbin/nologin`, password locked (`L`) — confirmed no usable password on any of the four | Observed (B4, 2026-08-06) |
| Directory layout | `/opt/<app>/{releases,shared}`, mode `750`, owned by the app's own user:group. **`current` deliberately not created yet** — it's a symlink to a real release, and none exists until B5's canary or a later real deploy | Observed (B4, 2026-08-06) |
| Credentials directories | `/etc/credentials/<app>/`, mode `700`, root:root — the path `reference/systemd`'s `LoadCredential=` units expect (`ADR-130`). Empty; no real secrets placed yet | Observed (B4, 2026-08-06) |

### Storage

| Fact | Value | Evidence |
|---|---|---|
| Databases | **PostgreSQL 16.14** (`Ubuntu 16.14-1.pgdg26.04+1`, from the official PGDG repository — not Ubuntu's own default version — to guarantee an exact match with `CS-DAT-010`'s observed `rms` requirement) and **Redis 8.0.5** (package genuinely named `redis-server`, not Valkey — see note below) both installed, `active`, `enabled`, and functionally verified (`psql` returned a version row; `redis-cli ping` returned `PONG`). No database, role, or dataset has been created — this is the empty engine only | Observed (B3, 2026-08-06) |
| Redis vs. Valkey | Worth recording explicitly: several distros replaced `redis-server` with the Valkey fork after Redis Ltd.'s 2024 licensing change (RSALv2/SSPLv1, no longer OSI-open). Ubuntu 26.04 still ships genuine Redis — Redis Ltd. moved Redis 8.0 back to AGPLv3, which is presumably why. Confirmed via `dpkg -l` (`redis-server 5:8.0.5-1`), not assumed from the package name alone | Observed (B3, 2026-08-06) |
| Node.js / npm | Node.js **v24.19.0**, npm **11.17.0**, both at `/usr/bin/` — an absolute, discoverable path, satisfying `reference/systemd`'s `{{NODE_BIN}}` prerequisite. Installed via NodeSource (Ubuntu's own apt repo carries a far older version); `setup_24.x` was used as an estimate of the current Active LTS line based on Node's release cadence, and the installed version confirms it was correct | Observed (B3, 2026-08-06) |
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
- Reference Implementations: `reference/systemd` (host prerequisites, incl. per-app directory layout, now fully met — ready for B5 canary), `reference/nginx` (nginx present, awaiting SOCX config), `reference/terraform`, `reference/deployment`, `reference/application` (all pending)
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
| 0.8     | 2026-08-06 | Bootstrap Phase B3 executed: nginx, PostgreSQL 16.14, Redis 8.0.5, Node.js v24.19.0/npm 11.17.0, and certbot installed and functionally verified. Runtime substrate now present; no application-level deployment yet | Socx   |
| 0.9     | 2026-08-06 | Bootstrap Phase B4 executed: per-app system users, `/opt/<app>` directory layout, and root-only credentials directories created for all four systems; recorded pre-existing DigitalOcean droplet-agent discovered during inspection | Socx   |

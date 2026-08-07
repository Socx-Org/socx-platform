---
id: CS-INF-020
title: Current Infrastructure Inventory
category: Infrastructure
status: Approved
gap_status: Diverges
confidence: High
owner: Platform Engineering
version: "1.2"
last_reviewed: 2026-08-07
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
  reference:
    - reference/systemd
    - reference/nginx
  runbooks: []
supersedes:
  - CS-INF-010
superseded_by: null
---
# CS-INF-020 — Current Infrastructure Inventory

## Scope

The actual hosting, network, and configuration facts for the platform's infrastructure as of the greenfield rebuild baseline (`ADR-180`). Supersedes `CS-INF-010`, which described the original droplet, decommissioned in July 2026 and retained as the historical record.

## Method

Five sources: **(a)** provisioning attestation from the platform owner, dated 2026-07-15 (droplet specification, access model, legacy-data disposition); **(b)** direct DNS observation (`dig` A-record lookups performed from an external network), dated 2026-07-15 and 2026-08-06 (nameserver/proxy-status recheck); **(c)** a second provisioning attestation, dated 2026-08-06, recording that the droplet was rebuilt a second time (Ubuntu 26.04 LTS, same reserved IP, DNS managed via Cloudflare and left unchanged) before any bootstrap execution occurred; **(d)** direct SSH inspection via Platform Bootstrap Phases B0–B5, dated 2026-08-05/06, culminating in a functional end-to-end verification (a disposable canary service run under `reference/systemd`'s actual units, then torn down); **(e)** independent `dig`/`whois` lookups performed outside the droplet, 2026-08-06. This inventory is considered verified, not merely drafted — see Revision History. One fact remains genuinely unresolved: the domain registrar's name specifically (distinct from its nameservers, which are confirmed).

## Inventory

**Headline:** Platform Bootstrap (Phases B0–B5) is complete, and the edge is now real. The runtime substrate is installed (B0–B3), platform scaffolding is in place (B4), and the whole stack has been functionally proven end-to-end (B5, via `reference/systemd`'s canary). Beyond bootstrap: **real production TLS certificates are issued for all four domains, real per-app nginx site configuration replaces the stock default page, and one full public-internet-to-app path (`ghs`) has been proven working over HTTPS** via a second disposable canary, then torn down. Both `reference/systemd` and `reference/nginx` are now `Approved`. **Still no real application code deployed** — `rms`, `ams`, and `www`/`socx.org.uk` correctly return `502 Bad Gateway` on their real domains, since nothing is listening on their upstream ports yet; this is the expected, honest state pending Deliverable 6.7/6.8, not a defect. No databases created, no scheduled jobs, no backups. Access hardening is complete except one standing, owner-directed exception: root SSH login by key remains permitted — see Access below.

### Hosting

| Fact | Value | Evidence |
|---|---|---|
| Provider / shape | DigitalOcean, single droplet (same reserved IP retained across the 2026-08-06 rebuild); kernel `7.0.0-29-generic` (upgraded from `7.0.0-27-generic` in Bootstrap Phase B2, confirmed running post-reboot), KVM virtualisation | Observed (B0 initial; B2 post-reboot) |
| Operating system | Ubuntu 26.04 LTS ("resolute"); **systemd 259 (259.5-0ubuntu3) confirmed** — clears `reference/systemd`'s ≥ 245 floor comfortably | Observed (B0) |
| Hostname / networking | Static hostname `prod-lab-01`. Public `209.97.135.128`; private networking `10.16.0.5`, `10.106.0.2`; IPv6 `2a03:b0c0:1:e0:0:1:6ca0:2001` | Observed (B0) |
| Resources | 1 vCPU, 956 MiB RAM, 24 GB disk. Post-install (all of B0–B5): **749 MiB available** RAM (206 MiB genuinely used by running services — nginx, PostgreSQL, Redis, sshd, droplet-agent, etc.; the rest is reclaimable cache), disk **3.3 GB used / 20 GB available (15%)**. Healthy headroom for now — the 9.8 MB canary process was trivial, but a real Express app with dependencies will use meaningfully more; worth re-checking once actual applications deploy (6.7/6.8) | Observed (B0 pre-install baseline; B5 post-install remeasurement, 2026-08-06) |
| Environment tier | `prod-lab-01` still serves as production with no non-production tier under this repository's management (`OPS-010.1` exception, `ADR-180`, remains open). A full DigitalOcean account query during `reference/terraform`'s real `import` (2026-08-07) found a second, previously-undocumented droplet — `dev-lab-01` (id `564856486`, `139.59.188.136`, `lon1`, `s-1vcpu-1gb`, **Ubuntu 24.04 LTS** — an older release than `prod-lab-01`'s confirmed 26.04). Explicitly **not** adopted as the non-production tier, imported, or otherwise acted upon in that round, at the platform owner's direction — its disposition is untriaged, a separate decision | Observed (B0 attestation for `prod-lab-01`; `dev-lab-01` discovered via DigitalOcean API query, 2026-08-07) |
| Provisioning method | `prod-lab-01`: was manual; **`OPS-020` exception now closed** — `reference/terraform` performed a real `terraform import`, reaching a genuine zero-diff `plan` against live infrastructure, 2026-08-07 (`ADR-180` amendment) | Observed (2026-08-07) |
| Time sync | NTP active, clock synchronised (`Etc/UTC`) | Observed (B0) |
| Pending OS updates | **Applied in Bootstrap Phase B2** (`apt-get upgrade` + `dist-upgrade`, including the kernel bump above). ~20 packages remain upgradable — confirmed to be Ubuntu's phased-rollout holdouts (the systemd package family, all pinned at an identical version bump, plus a handful of others), not a gap; they apply automatically via `unattended-upgrades` (2.12ubuntu9, confirmed active: `APT::Periodic::Update-Package-Lists` and `Unattended-Upgrade` both `"1"`) as Canonical's rollout reaches this host. Not something to force manually — doing so would defeat phasing's safety purpose | Observed (B2, 2026-08-06) |

### DNS

| Fact | Value | Evidence |
|---|---|---|
| A records | `socx.org.uk`, `ghs.`, `rms.`, `ams.` → `209.97.135.128`; `www`, `www.ghs`, `www.rms`, `www.ams` → CNAME → their respective apex/subdomain. All 8 records confirmed via a direct Cloudflare API query (not just `dig`) during `reference/terraform`'s real `import`, including the three `www.<app>` CNAMEs `dig`-based observation alone had missed — now all 8 are Terraform-managed | Observed (`dig`, 2026-07-15; full Cloudflare API record listing, 2026-08-07) |
| DNS management | Cloudflare. The 2026-08-06 droplet rebuild retained the same IP, so no repointing was required or performed. **Nameservers confirmed:** `brett.ns.cloudflare.com`, `cruz.ns.cloudflare.com`. Zone ID confirmed: `77791e5cb6be800c2a5c54e869f7e834` | Observed (`dig NS`, 2026-08-06; Cloudflare API, 2026-08-07) |
| Proxy status | **DNS-only, not proxied**, on every record (confirmed for all 8 via the Cloudflare API, not inferred). TTL: `1` ("automatic") on every record | Observed (`dig A`, 2026-08-06; Cloudflare API, 2026-08-07) |
| Registrar (name) | Unknown — a `whois` lookup returned no data. Low-stakes gap: doesn't affect anything operational, since DNS management (Cloudflare) and record content are already confirmed | Not yet resolved |

### TLS Certificates

**Real production Let's Encrypt certificates issued for all four domains** (2026-08-06, via `certbot certonly --webroot`, which never modifies nginx config itself): `ghs.socx.org.uk`, `rms.socx.org.uk`, `ams.socx.org.uk`, and a single certificate covering both `socx.org.uk` and `www.socx.org.uk`. All ECDSA, all expiring 2026-11-04, `certbot.timer` confirmed active for automatic renewal. **Observed nuance:** nginx logs a harmless `ssl_stapling` warning against these certificates ("no OCSP responder URL") — stapling is skipped, TLS itself is unaffected; not a defect, documented in `reference/nginx`'s manifest so it isn't mistaken for one. — Observed (on-host deployment, 2026-08-06)

### Reverse Proxy

**Real per-app site configuration deployed** (2026-08-06), replacing the stock default page entirely — confirmed gone via a deliberately-unmatched `Host` header test (now returns a clean `404` from our own config, not nginx's default welcome content). One TLS-terminating site file per domain (`reference/nginx`'s `sites/*.conf`, unmodified except placeholder substitution), all `include`-ing the shared TLS baseline. Redirect (`80→443`) and TLS both confirmed working on all five hostnames. `rms`, `ams`, and `socx.org.uk`/`www.socx.org.uk` currently `502` on the HTTPS request itself — correct and expected, since no application is listening on their upstream ports yet. `ghs` was additionally proven end-to-end: a disposable canary (same pattern as Bootstrap B5) served a real `200` response through the full path — public internet → TLS → nginx → app — including the `X-SOCX-Environment: production` header, then was cleanly torn down, returning `ghs` to the same honest `502` state as its siblings. — Observed (on-host deployment, 2026-08-06)

### System Services

`sshd` (ports 22, IPv4+IPv6), loopback-only `systemd-resolved`, plus (as of B3) **nginx** (port 80, externally reachable — allowed by the firewall), **PostgreSQL 16** and **Redis 8.0.5** (both local-only by default, not exposed through the firewall), and **certbot.timer**. Also present, **pre-existing and vendor-provided, not installed by this bootstrap**: DigitalOcean's **`droplet-agent`** (1.4.0, `active`/`running`) and its `droplet-agent-update.timer` (hourly) — discovered while inspecting `/opt/` during B4; confirmed via `dpkg -l` and `systemctl`, not assumed. No application units currently present — `reference/systemd`'s direct-execution unit was proven working via a disposable canary in Bootstrap Phase B5 (`systemd-analyze verify`, clean start, restart survival, clean teardown), then removed; the next such unit installed here will run a real application. — Observed (B0 baseline; B3 additions; B4 discovery; B5 verification)

### Scheduled Jobs

None application-level (accordingly, **no backups run** — nothing exists yet to back up). `droplet-agent-update.timer` (hourly, DigitalOcean-provided) is the only timer present. — Observed (B4)

### Application Scaffolding

Created in Bootstrap Phase B4, for each of the four systems (`socx-org-uk`, `ghs`, `rms`, `ams`, per `CS-DOM-010`); **the pattern was functionally proven end-to-end on `ghs` in Bootstrap Phase B5**, then reset to this clean baseline:

| Fact | Value | Evidence |
|---|---|---|
| System users | One dedicated, non-interactive account per app (system UIDs 106–109), home `/nonexistent`, shell `/usr/sbin/nologin`, password locked (`L`) — confirmed no usable password on any of the four. `750` on `/opt/<app>` also confirmed to correctly deny access to unrelated accounts (surfaced incidentally when a verification command run as `deploy`, without `sudo`, was correctly refused) | Observed (B4; access-control re-confirmed B5, 2026-08-06) |
| Directory layout | `/opt/<app>/{releases,shared}`, mode `750`, owned by the app's own user:group. `current` is currently absent again — B5 created it pointing at a disposable canary release, proved the pattern works (systemd started, read, and served from it), then removed it as part of teardown. The **next** `current` symlink created here will be for a real release | Observed (B4 baseline; B5 pattern proof and clean reset, 2026-08-06) |
| Credentials directories | `/etc/credentials/<app>/`, mode `700`, root:root — the path `reference/systemd`'s `LoadCredential=` units expect (`ADR-130`). Currently empty again — B5 placed two dummy credentials (`db_password`, `jwt_secret`) in `ghs`'s directory, confirmed both were readable via the unit's `LoadCredential=` sandbox **without their values ever appearing in logs** (`SEC-010.5`), then removed them | Observed (B4 baseline; B5 functional proof and clean reset, 2026-08-06) |

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
| Edge, runtime, scaffolding | nginx (real config + certs, all four domains), PostgreSQL, Redis, Node.js installed; per-app systemd pattern proven working (B0–B5, then again for the edge) | Shared nginx edge → systemd-managed processes | Closed | Both `reference/systemd` and `reference/nginx` are `Approved`, verified on this host |
| Application deployment | No real application code deployed anywhere — 3 of 4 domains correctly `502` | Systems running behind the edge | Fully open | Deliverable 6.7/6.8 |
| Governance exceptions | Hand-provisioned; single tier | `OPS-020`; `OPS-010.1` | Two open `GEN-010.9` exceptions | Time-boxed, tracked in `ADR-180`, closed by `reference/terraform` |

## Related Documents

- Architecture: `INF-010`
- Standards: `OPS-010`, `OPS-020` (both under recorded exception)
- ADRs: `ADR-180` (the transition this baselines), `ADR-040`
- Reference Implementations: `reference/systemd`, `reference/nginx` (both **Approved** — verified end-to-end on this host, 2026-08-06); `reference/security`, `reference/deployment`, `reference/application` (all **Approved** — verified end-to-end on this host via a disposable `canary-app` exercise, 2026-08-07); `reference/terraform` (**Approved** — real `import` of this droplet and its DNS records, zero-diff `plan` reached, 2026-08-07); `reference/monitoring` (**Approved** — real `apply`: live uptime checks/alerts against this droplet's real domains, real journald retention config installed on this host, 2026-08-07). 7 of 8 `reference/` categories now Approved; only `reference/github` remains Draft (branch protection deliberately deferred)
- Runbooks: none yet — the B1 access-hardening sequence and the B5 canary procedure are candidate first entries for Deliverable 7
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
| 1.0     | 2026-08-06 | Bootstrap Phase B5 executed: `reference/systemd` verified end-to-end via disposable canary (moved to Approved), then cleanly torn down; DNS nameservers and proxy-status resolved independently; post-install resource headroom measured. Moved to **Approved** — inventory verified, not merely drafted, per the Current-State lifecycle. One minor gap remains: domain registrar name specifically | Socx   |
| 1.1     | 2026-08-06 | On-host `reference/nginx` deployment: real production TLS certificates issued for all four domains; real per-app site config deployed, replacing the stock default page; redirect/TLS confirmed on all five hostnames; `ghs` proven end-to-end via a second disposable canary, then cleanly torn down. `reference/nginx` moved to Approved | Socx   |
| 1.2     | 2026-08-07 | `reference/security`, `reference/deployment`, `reference/application` verified end-to-end via a disposable `canary-app` exercise, moved to Approved. `reference/terraform` performed a real `import` of the droplet and all 8 real DNS records (previously-unknown `www.<app>` CNAMEs included), reaching a zero-diff `plan`; `ADR-180`'s `OPS-020` exception closed. A second, previously-undocumented droplet (`dev-lab-01`) found via a full DigitalOcean API query, explicitly left untriaged | Socx   |

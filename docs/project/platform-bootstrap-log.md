# Platform Bootstrap Log

Chronological execution record for the Platform Bootstrap Plan (`docs/project/platform-bootstrap-plan.md`). Raw command output, redacted of any secret values (`SEC-010.5`) — credential *placement* is recorded, never credential *values*. This log is the seed material for the first operational runbooks (Deliverable 7).

---

## Phase B0 — Preflight & fact confirmation

**Executed:** 2026-08-05 (droplet local clock; session date 2026-08-06) · **Host:** `209.97.135.128` (`prod-lab-01`) · **Operator:** platform owner, via existing SSH session

### Command output (verbatim, no secrets present)

```
=== B0.1 OS release ===
Distributor ID:	Ubuntu
Description:	Ubuntu 26.04 LTS
Release:	26.04
Codename:	resolute
=== B0.2 Kernel / virt ===
7.0.0-27-generic
kvm
=== B0.3 systemd version ===
systemd 259 (259.5-0ubuntu3)
=== B0.4 Hostname ===
prod-lab-01
209.97.135.128 10.16.0.5 10.106.0.2 2a03:b0c0:1:e0:0:1:6ca0:2001
=== B0.5 Time sync ===
               Local time: Wed 2026-08-05 23:31:10 UTC
           Universal time: Wed 2026-08-05 23:31:10 UTC
                 RTC time: Wed 2026-08-05 23:31:10
                Time zone: Etc/UTC (UTC, +0000)
System clock synchronized: yes
              NTP service: active
=== B0.6 Current user ===
root
uid=0(root) gid=0(root) groups=0(root)
=== B0.7 Human accounts ===
ubuntu 1000 /bin/bash
deploy 1001 /bin/bash
=== B0.8 Root account state ===
root L 2014-04-16 0 99999 7 -1
=== B0.9 Effective SSH policy ===
permitrootlogin yes
pubkeyauthentication yes
passwordauthentication no
kbdinteractiveauthentication no
=== B0.10 Firewall as found ===
Status: inactive
=== B0.11 Listening ports ===
LISTEN  0.0.0.0:22   sshd
LISTEN  127.0.0.54:53  systemd-resolve
LISTEN  127.0.0.53%lo:53  systemd-resolve
LISTEN  [::]:22  sshd
=== B0.12 Pending updates ===
6
ii  unattended-upgrades 2.12ubuntu9  all  automatic installation of security upgrades
=== B0.13 Resources ===
1
Mem: 956Mi total, 214Mi used, 166Mi free, 599Mi buff/cache, 741Mi available
Disk /: 24G total, 2.2G used, 21G avail, 10% used
=== B0.14 Clean-slate check ===
node: absent
npm: absent
psql: absent
redis-server: absent
nginx: absent
certbot: absent
terraform: absent
```

### Findings

| # | Finding | Severity | Disposition |
|---|---|---|---|
| 1 | `PermitRootLogin yes` — root SSH login by key currently works (root password itself is locked) | Real, actionable | Remediate in B1: `PermitRootLogin no` |
| 2 | Two human accounts (`ubuntu`, `deploy`), not the one previously attested. `deploy` created by an untracked local script (`create-deploy-user-on-droplet.sh`) which copied root's `authorized_keys` onto it — explains finding #1 and why B0 ran as root | Real, explained | Remediate in B1: disable `ubuntu`; `deploy` remains the standing admin account |
| 3 | Droplet is small: 1 vCPU / ~956 MiB RAM / 24 GB disk | Informational | No action now — watch during Phase B3 (Node + PostgreSQL + Redis + nginx together) |
| 4 | Everything else (OS, systemd version, firewall, listeners, clean-slate binaries, DNS/IP) matches the `CS-INF-020` attestation | Confirms baseline | None |

### Documentation updated as a result

- `docs/current-state/infrastructure/CS-INF-020-current-infrastructure-inventory.md` → v0.3 (Attested → Observed across Hosting/Access/Storage; findings #1–#3 recorded)
- `docs/current-state/identity/CS-IAM-010-current-identity-and-access-inventory.md` → v2.1 (account count and root-login finding corrected)

### Outcome

B0 complete. Proceeding to B1 pending approval, incorporating findings #1 and #2 into the B1 command set.

---

## Interim finding — `deploy` sudo non-functional (discovered 2026-08-06, between B0 and B1)

While preparing for B1, the platform owner found that `sudo` from the `deploy` account always prompts for a password that cannot be supplied — `deploy` was created via `adduser --disabled-password` (no password hash) and added to the `sudo` group via plain `usermod -aG sudo`, which requires the invoking user's own password under Ubuntu's default policy. This explains B0.6's `whoami: root` — the operator was SSH'd in directly as root because `deploy` could not sudo.

**Fix (pending execution):** a scoped `NOPASSWD` sudoers drop-in for `deploy` (`/etc/sudoers.d/deploy`), syntax-checked with `visudo -c` before use, verified by a `sudo whoami` test from a **separate, fresh SSH session** before any change to root's SSH login is made. This step now gates the start of B1's SSH-hardening work, precisely to avoid a lockout.

**Documentation updated:** `CS-INF-020` → v0.4.

**Resolved 2026-08-06:** fix applied and verified — `ssh deploy@209.97.135.128 'sudo whoami'` from a separate session returned `root`, no password prompt. `deploy` is now a fully functional administrative account. The source script (`automation/create-deploy-user-on-droplet.sh`, outside this repository) was also updated so future droplets don't hit the same issue: it now writes the sudoers rule to a temp file, validates it with `visudo -cf` before installing, and prints the same verification reminder.

---

## Phase B1 — Access hardening: **COMPLETE, except root login (standing exception)**

**Status as of 2026-08-06:**

| Step | State |
|---|---|
| (1) `deploy` passwordless sudo | ✅ Done and verified |
| (2) Disable root SSH login (`PermitRootLogin no`) | ⏸ **Standing exception** — platform owner's explicit, reiterated direction: proceed with the rest of B1, leave root login untouched |
| (3) Decide `ubuntu` account's fate | ✅ Done — locked (password `L`, shell `/usr/sbin/nologin`); no `authorized_keys` found (nothing to neutralize) |
| (4) Enable UFW (22/80/443 only) | ✅ Done — active, default deny (incoming) / allow (outgoing), exactly 22/80/443 (v4+v6) |
| (5) Confirm `unattended-upgrades` active | ✅ Done — already active in the base image before any bootstrap action; `dpkg-reconfigure` confirmed both settings `"1"` |

### Command output (B1 continued, verbatim)

```
=== B1.1 Ubuntu account: lock password, disable shell ===
ubuntu L 2026-08-05 0 99999 7 -1
=== B1.2 Ubuntu account: neutralize any SSH keys ===
no authorized_keys file for ubuntu
=== B1.3 Firewall: default-deny, allow 22/80/443 only ===
Default incoming policy changed to 'deny'
Default outgoing policy changed to 'allow'
Rules updated / Rules updated (v6)  [x3 — 22, 80, 443]
Firewall is active and enabled on system startup
Status: active
Default: deny (incoming), allow (outgoing), disabled (routed)
To                         Action      From
22/tcp                     ALLOW IN    Anywhere
80/tcp                     ALLOW IN    Anywhere
443/tcp                    ALLOW IN    Anywhere
22/tcp (v6)                ALLOW IN    Anywhere (v6)
80/tcp (v6)                ALLOW IN    Anywhere (v6)
443/tcp (v6)                ALLOW IN    Anywhere (v6)
=== B1.4 Unattended-upgrades: confirm active ===
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
```

Full session output (including the post-firewall-enable B1.4 section) returned intact, confirming the active SSH session survived the firewall change without disruption.

**Root login — standing exception, not a pause.** Reframed from the earlier "postponed" language: the owner has now twice directed that root login stay enabled — first to defer it, then explicitly excluding it while approving the rest of B1. This is recorded as a deliberate, indefinite operational choice with no scheduled resumption, not a formal `GEN-010.9` exception (`SEC-030` has no specific numbered requirement mandating root-login be disabled). **Residual risk:** root SSH login by key remains a second path to full privilege alongside `deploy`'s now-verified sudo.

**Documentation updated:** `CS-INF-020` → v0.6, `CS-IAM-010` → v2.2.

### Outcome

B1 is functionally complete for the purpose of proceeding to B2, with root-login-permitted carried forward as a standing, recorded exception rather than a blocker.

---

## Phase B2 — System baseline: **COMPLETE**

**Executed:** 2026-08-06 · **Tracked under:** #76

### Summary

Applied the 6 pending package updates from B0.12, hit a routine dpkg conffile prompt on `openssh-server`'s `sshd_config` (resolved: kept local — DigitalOcean's image customization, not something we'd changed, and not worth risking against the standing root-login exception), then discovered `apt-get upgrade` alone doesn't fully patch a host — Ubuntu's conservative `upgrade` skips anything needing dependency changes, and phased rollout deliberately withholds some updates regardless. Ran `dist-upgrade` to catch the former; the latter (~19-20 packages, largely the systemd family at a coordinated version bump) is expected and left alone.

A new kernel (`7.0.0-29-generic`, up from `7.0.0-27-generic`) required a reboot. Used the reboot as a deliberate opportunity to verify B1's hardening (sudo, firewall, account lockout) persists across a restart rather than just existing in the session that created it — first real test of that.

### Key command output (condensed; full session output was longer)

```
=== B2.1 upgrade ===
[6 packages applied; interactive prompt for /etc/ssh/sshd_config -> kept local version]
=== B2.2 reboot required? ===
*** System restart required ***
=== B2.3 hostname ===
prod-lab-01  (unchanged, confirmed intentional)
=== B2.4 time sync (pre-dist-upgrade) ===
System clock synchronized: no   <- transient, chrony had just been auto-restarted by needrestart
=== B2.5 upgradable count ===
23
--- investigation round ---
=== B2.6 apt list --upgradable ===
23 packages, all resolute-updates pocket
=== B2.7 chronyc tracking / timedatectl (recheck) ===
System clock synchronized: no   <- still settling
=== B2.8 dist-upgrade ===
[new kernel 7.0.0-29-generic installed; GRUB updated; "Pending kernel upgrade!" from needrestart]
=== B2.9 upgradable count ===
19
=== B2.10 reboot required? ===
*** System restart required ***
--- re-verification round ---
=== B2.6 (re-run) apt list --upgradable ===
19 packages: apparmor, bind9-{dnsutils,host,libs}, cloud-init(-base), libapparmor1,
systemd family (libnss-systemd, libpam-systemd, libsystemd-shared, libsystemd0,
libudev1, systemd, systemd-cryptsetup, systemd-resolved, systemd-sysv, udev),
python3-software-properties, software-properties-common
  -> all resolute-updates pocket; systemd family pinned at identical version bump
     (259.5-0ubuntu3 -> 259.5-0ubuntu3.3), consistent with a deliberately staged
     rollout rather than a missed/failed install
=== B2.7 (re-run) chronyc tracking / timedatectl ===
Stratum 3, sub-millisecond offset, Leap status: Normal
System clock synchronized: yes   <- resolved, as expected once chrony settled
=== B2.11 reboot ===
sudo reboot
=== B2.12 post-reboot verification ===
uname -r:             7.0.0-29-generic          (new kernel loaded)
sudo whoami (deploy):  root, no password prompt  (sudo fix survived reboot)
ufw status verbose:    active, same 6 rules      (firewall survived reboot)
passwd -S ubuntu:       L                        (lockout survived reboot)
timedatectl:            synchronized: yes        (still healthy)
reboot-required flag:   cleared
upgradable count:       20  (+1 vs pre-reboot; ordinary apt-daily-timer index
                             churn in the background, not a regression)
```

### Findings

| # | Finding | Disposition |
|---|---|---|
| 1 | `sshd_config` conffile prompt during upgrade | Kept local version — preserves the tested SSH policy, including the standing root-login exception; not something to risk against an unreviewed maintainer default |
| 2 | Plain `apt-get upgrade` left packages behind | Standard Ubuntu behavior (won't add/remove packages to satisfy deps); `dist-upgrade` closed most of the gap |
| 3 | ~19-20 packages remain permanently upgradable for now | Confirmed as Ubuntu's phased-rollout mechanism (systemd family at a coordinated pinned version), not an error; resolves automatically via `unattended-upgrades` over time — not forced |
| 4 | `System clock synchronized: no` immediately after B2.1 | Transient — chrony was auto-restarted by needrestart as part of the upgrade; resolved on its own within the same session |
| 5 | B1 hardening (sudo, firewall, account lockout) | All confirmed to survive a full reboot, not just present in the session that created them |

### Documentation updated

- `docs/current-state/infrastructure/CS-INF-020-current-infrastructure-inventory.md` → v0.7 (kernel version, patch state, phased-package explanation, reboot-persistence confirmation)

### Outcome

B2 complete. Proceeding to B3 (Runtime & core services) pending review and approval, per the mandatory GitHub workflow (Phase 3 — this documentation is presented for review before commit).

---

## Phase B3 — Runtime & core services: **COMPLETE**

**Executed:** 2026-08-06 · **Tracked under:** #76

### Summary

Installed the approved stack: nginx (`ADR-050`), PostgreSQL 16 via the official PGDG repo (`ADR-090`), Redis via apt (`ADR-090`), Node.js via NodeSource (`ADR-070`), and certbot with its nginx plugin. All five verified functionally, not just installed — HTTP 200 from nginx, a real SQL query against PostgreSQL, `PONG` from Redis, working `node`/`npm`, `certbot --version`. Firewall re-confirmed unchanged.

First round of output only showed the certbot/firewall tail (same partial-paste pattern as B2); a targeted re-check of the missing four components confirmed all had succeeded.

### Key command output (condensed)

```
=== B3.2 nginx ===
active / enabled / HTTP/1.1 200 OK

=== B3.3 PostgreSQL (via PGDG) ===
active / enabled
PostgreSQL 16.14 (Ubuntu 16.14-1.pgdg26.04+1) on x86_64-pc-linux-gnu ...

=== B3.4 Redis ===
ii  redis-server   5:8.0.5-1   amd64   Persistent key-value database with network interface
ii  redis-tools    5:8.0.5-1   amd64   ...
active
PONG

=== B3.5 Node.js (via NodeSource setup_24.x) ===
/usr/bin/node
v24.19.0
/usr/bin/npm
11.17.0

=== B3.6 certbot ===
Setting up certbot (4.0.0-4) ... / python3-certbot-nginx (4.0.0-3)
certbot.timer enabled
certbot 4.0.0

=== B3.7 firewall (re-check) ===
active, same 6 rules as B1/B2 (22/80/443 x v4/v6) -- unchanged
```

### Findings

| # | Finding | Disposition |
|---|---|---|
| 1 | PostgreSQL via PGDG, not Ubuntu's default repo | Guarantees exactly version 16, matching `rms`'s stated requirement (`CS-DAT-010`) rather than whatever Ubuntu 26.04 happens to default to |
| 2 | Redis is genuine Redis 8.0.5, not Valkey | Worth recording explicitly — several distros substituted Valkey after Redis Ltd.'s 2024 licensing change; Ubuntu 26.04 still ships real Redis, likely because Redis 8.0 moved back to AGPLv3. Confirmed via `dpkg -l`, not assumed from the package name |
| 3 | NodeSource `setup_24.x` estimate confirmed correct | Installed `v24.19.0`, consistent with Node's known release cadence (new Active LTS each October on even majors) |
| 4 | First round of output was a partial paste (certbot + firewall only) | Same pattern as B2; targeted re-check requested for just the missing four components rather than re-running installs |
| 5 | Firewall unaffected by any of the five installs | Confirmed unchanged from B1/B2's state |

### Documentation updated

- `docs/current-state/infrastructure/CS-INF-020-current-infrastructure-inventory.md` → v0.8 (Reverse Proxy, TLS Certificates, System Services, Storage sections updated; Related Implementations expanded)
- `docs/current-state/technology/CS-TEC-010-current-technology-inventory.md` → v2.2 (Hosting, Reverse proxy, Database, Cache/queue, Process management rows updated with host-level observations; fixed a stale "ADRs: none yet")

### Outcome

B3 complete. Runtime substrate fully installed and verified; still no application-level deployment. Proceeding to B4 (Platform scaffolding) pending review and approval, per the mandatory GitHub workflow.


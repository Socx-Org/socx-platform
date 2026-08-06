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

## Phase B1 — Access hardening: **PARTIALLY EXECUTED, PAUSED**

**Status as of 2026-08-06:**

| Step | State |
|---|---|
| (1) `deploy` passwordless sudo | ✅ Done and verified |
| (2) Disable root SSH login (`PermitRootLogin no`) | ⏸ Postponed — platform owner's explicit request |
| (3) Decide `ubuntu` account's fate | ⏸ Postponed |
| (4) Enable UFW (22/80/443 only) | ⏸ Postponed |
| (5) Confirm `unattended-upgrades` active | ⏸ Postponed |

**Reason:** the platform owner asked to postpone the remaining hardening steps for now, having just confirmed `deploy`'s sudo access works. No rationale beyond timing was given; not a response to any blocker.

**Residual risk while paused:** root SSH login by key remains active; firewall remains inactive. Recorded in `CS-INF-020` v0.5 as a knowingly accepted, deferred task — not a formal `GEN-010.9` exception, since `SEC-030` has no specific numbered requirement mandating root-login be disabled.

**Documentation updated:** `CS-INF-020` → v0.5.


---
status: Draft
verified: null   # required before Approved: "<nginx version>, <OS>, <method>, YYYY-MM-DD"
---

# reference/nginx — Edge & Site Configuration

## Purpose & Scope

Canonical nginx configuration for the platform's shared edge (`ADR-050`): one TLS-terminating site file per application, plus the shared TLS baseline they all include. Demonstrates the target topology `INF-010` describes — a single shared edge in front of every application, with no application directly internet-facing.

Explicitly not covered here:

- **Certificate issuance and renewal procedure** — this config assumes certificates already exist at the standard Let's Encrypt paths; obtaining them is an operational step (Usage, below), and ongoing renewal is runbook content (Deliverable 7)
- **Application-level routing** — each app owns its own routes entirely; this config never rewrites or inspects request paths
- **The applications themselves** — `reference/application` (Deliverable 6.8)
- **Deploy/reload automation** — `reference/deployment` (Deliverable 6.7)

## Contents

| File | Role |
|---|---|
| `snippets/tls-baseline.conf` | Shared TLS protocol/cipher/HSTS/OCSP configuration, included by every site file |
| `sites/ghs.conf`, `sites/rms.conf`, `sites/ams.conf` | Identical single-domain site template, one file per app |
| `sites/www.conf` | Same pattern, adapted for `socx-org-uk`'s two server names (apex + `www`) |

## Design Decisions

- **No path rewriting between nginx and the app — ever.** `CS-INF-010` recorded a confirmed outage: the old config stripped `/api/` before proxying, so Express received a path it never expected. Every `proxy_pass` here has no trailing path component, so the full request URI passes through unchanged. This removes the whole bug class structurally rather than requiring every future config author to get a rewrite rule right.
- **One site file per application.** This does **not** give nginx runtime fault isolation — a syntax error in any included file still fails `nginx -t` for the entire instance; nginx does not skip a broken vhost. What it buys is editability and blast-radius containment **during changes**: touching `ghs.conf` cannot accidentally corrupt `rms.conf`, and diffs stay per-app. This is exactly why `nginx -t` before every reload is a mandatory step below, not a suggestion.
- **TLS baseline factored into a shared snippet.** Protocol/cipher/HSTS policy is defined once and included everywhere, so it can't drift per-app; only the genuinely domain-specific `ssl_certificate`/`ssl_certificate_key` paths live in each site file.
- **HTTP exists only to redirect.** No application traffic is ever served over plain `:80`; the redirect is the entire content of that server block.
- **`X-SOCX-Environment` header.** Makes the environment tier identifiable at the edge (`OPS-010.2`), complementing `reference/systemd`'s `SOCX_ENV` at the process level — two independent places to see which tier is serving a request.

## Compliance

Deliberately short — this artefact's value is mostly architectural (realising `ADR-050`/`INF-010` and structurally preventing the `CS-INF-010` incident class), not a long list of Standards line-items:

| Requirement | Satisfied by |
|---|---|
| OPS-010.2 | Every site file — `add_header X-SOCX-Environment {{ENVIRONMENT}}` |

## Prerequisites

- **nginx installed**, per `reference/systemd`'s host or equivalent (confirmed present via Bootstrap Phase B3: nginx active, serving its default page)
- **Certificates already issued** at `/etc/letsencrypt/live/{{DOMAIN}}/{fullchain,privkey}.pem` — see Usage for how to obtain them; this config does not issue them itself
- **The application already running** on `127.0.0.1:{{APP_PORT}}` — via `reference/systemd`'s units; nginx proxies to it, it doesn't start it
- **DNS already pointing at this host** — confirmed for all four domains (`CS-INF-020`)

## Usage

Parameters: `{{APP_NAME}}`, `{{DOMAIN}}` (or `{{APEX_DOMAIN}}`/`{{WWW_DOMAIN}}` for `www.conf`), `{{APP_PORT}}`, `{{ENVIRONMENT}}` (per `OPS-010` tier).

1. Copy the relevant site file into the consuming repository/host, substituting all placeholders — grep for `{{` to confirm none remain.
2. Copy `snippets/tls-baseline.conf` to `/etc/nginx/snippets/` (shared, not per-app).
3. **Obtain the certificate before enabling the site**, e.g. `certbot certonly --nginx -d {{DOMAIN}}` (or `--webroot` if nginx isn't serving that domain yet) — this populates the paths the site file expects.
4. Install: copy to `/etc/nginx/sites-available/`, symlink into `sites-enabled/`.
5. **`nginx -t` before every reload, no exceptions** — a passing test is the only thing standing between one bad file and the whole edge going down (see Design Decisions).
6. `systemctl reload nginx`.
7. Re-verify: confirm the redirect (`curl -I http://{{DOMAIN}}`), confirm TLS (`curl -I https://{{DOMAIN}}`), confirm the app responds through the proxy, confirm `X-SOCX-Environment` is present. Record the nginx version, OS, method, and date in this manifest's `verified` field.

## Expected Adaptations

**Consuming projects are expected to customise:**

- All `{{PLACEHOLDER}}` values
- Additional `location` blocks for static assets, websockets, or other per-app routing needs
- Rate limiting, request size limits, or other edge policy specific to one app

**Must remain unchanged to preserve compliance:**

- No path rewriting on `proxy_pass` — reintroducing one is a regression to the `CS-INF-010` incident class
- The shared `tls-baseline.conf` include — per-site TLS overrides need a recorded reason (`GEN-010.9` exception; a permanent deviation is an ADR, `DOC-020.2`)
- HTTP serving only a redirect, never application content
- `nginx -t` before reload, always

## Related Documents

- Standards: `OPS-010`
- Architecture: `INF-010` (target topology this realises), `ADR-050`
- ADRs: `ADR-050` (shared edge decision)
- Current-State: `CS-INF-010` (the incident this structurally prevents), `CS-INF-020` (nginx already installed, Bootstrap Phase B3)
- Runbooks: none yet — certificate renewal and reload procedures are Deliverable 7 candidates
- Automation: reload/deploy glue pending in `reference/deployment` (Deliverable 6.7)

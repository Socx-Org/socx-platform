---
status: Approved
verified: "Applied for real to socx-platform itself, 2026-08-07: a real, working CI workflow authored and verified passing on the actual GitHub Actions runner first (a prerequisite this round confirmed is load-bearing -- applying protection with a required check that never runs makes a repository permanently unmergeable), then branch-protection applied via a real gh api call. Confirmed for real: a direct push to main after protection was applied succeeded only via the documented admin-bypass path (enforce_admins: false), with an explicit 'Bypassed rule violations' warning, then reverted. One real, structural blocker found and worked around: branch protection of any kind on a PRIVATE repository requires GitHub Pro on this account's plan -- confirmed via a rejected real API call on both the classic branch-protection endpoint and the newer rulesets endpoint, not assumed. socx-platform was made public to unblock this; the same constraint will apply to any private consuming repository."
---

# reference/github — CI/CD Workflows & Branch Protection

## Purpose & Scope

Canonical GitHub Actions pipeline and branch-protection configuration every SOCX repository adopts (`ADR-150`, `ADR-170`, `ENG-010`, `ENG-040`).

**What verification meant here, and what it found.** Unlike `reference/systemd`/`reference/nginx`, where verification meant exercising the artefact on a droplet, verifying this one for real meant applying branch protection to `socx-platform` itself — deliberately deferred for most of this engagement (recorded as a `GEN-010.9` exception, `docs/development/github-workflow.md`), then applied for real once the platform owner decided to proceed. It surfaced a real, previously-unknown constraint worth any consuming project knowing in advance: **branch protection on a private repository requires GitHub Pro** — confirmed via a real, rejected API call, not documentation. `socx-platform` was made public to unblock this. A future application repository intending to stay private needs either a paid plan or to accept this limitation before relying on this reference implementation.

Explicitly not covered here:

- **Real deploy mechanics** — the `deploy` job here is a gating stub only (proves `ENG-040.4`'s separation/trigger requirement); actual deploy steps are `reference/deployment` (Deliverable 6.7)
- **CODEOWNERS / code-owner-specific review routing** — `ENG-010.5` requires an independent approving review, not a code-owner-specific one; `require_code_owner_reviews` is deliberately `false`
- **The applications themselves** — `reference/application` (Deliverable 6.8)

## Contents

| File | Role |
|---|---|
| `workflows/ci.yml` | Install → lint → test → build pipeline, plus a gated (stub) deploy job |
| `branch-protection.json` | GitHub REST API payload for `main`'s protection rules |

## Design Decisions

- **Grounded in a real, working SOCX CI workflow, with corrections.** This was built from `rms`'s actual `.github/workflows/deploy.yml` — a genuinely useful starting point (npm-workspaces monorepo, a real Postgres service container for DB-backed tests, secrets referenced only by name) — but that file predates several since-made platform decisions and was corrected rather than copied: it has **no lint stage** despite a working `lint` script existing; it pins **Node `20`**, not the platform's actual current LTS (`ADR-070`; confirmed running as `v24.19.0` in Bootstrap Phase B3); its deploy trigger includes a **legacy branch** (`central-infra`) from before the rebuild; and its deploy job hand-rolls `nvm`/raw-SSH/`systemctl` choreography — exactly the fragility `ADR-040`/`CS-INF-010` retired. None of that carries forward.
- **The deploy job is a deliberate stub, not a placeholder to fill in per-project.** Its only job is to prove correct *gating* (`ENG-040.4`: a separate job, triggered only on push to `main`). Real deploy steps land here once `reference/deployment` (6.7) exists — a consuming project should wait for that, not improvise its own deploy steps into this file.
- **Stage order is the fail-fast mechanism, not a convention layered on top of one.** GitHub Actions steps run sequentially and stop at the first failure by default — writing `install → lint → test → build` in that literal order *is* `ENG-040.2`'s fail-fast requirement, nothing extra to configure.
- **Branch protection as a committed JSON payload, applied via `gh api`, not a manual settings walkthrough.** Matches the platform's infrastructure-as-code bias (`OPS-020`) and makes the rule set reviewable in a diff rather than living only in a UI.
- **`enforce_admins: true`.** Secure-by-default: administrators are not exempt from `main`'s protections unless a genuine exception is recorded (`GEN-010.9`). **`socx-platform`'s own real application of this file deliberately used `enforce_admins: false` instead** — a documented, single-contributor-specific deviation, not a change to this canonical default. `ENG-010.6` already anticipates the scenario: in a repository with no second reviewer, `required_approving_review_count >= 1` with `enforce_admins: true` makes the repository unable to merge its own work at all. `false` preserves every other protection (no direct push, no force-push, no unreviewed merge) for anyone else, while giving the actual admin a working bypass — confirmed for real, not assumed: a direct push after protection was applied succeeded only via that bypass, with an explicit warning, and was reverted. A consuming project with more than one real contributor should keep `enforce_admins: true` as written.
- **Branch protection requires the repository to be public, or GitHub Pro.** Found for real applying this to `socx-platform` (a private repository at the time): both the classic branch-protection endpoint and the newer rulesets endpoint reject any protection payload — even the most minimal one — with `403 Upgrade to GitHub Pro or make this repository public`. Not documented anywhere in this reference implementation before this round; now it is.

## Compliance

| Requirement | Satisfied by |
|---|---|
| ENG-040.1 | `ci.yml` — `on: pull_request` triggers CI on every PR |
| ENG-040.2 | `ci.yml`'s `ci` job — install → lint → test → build, in that literal order |
| ENG-040.3 | `branch-protection.json`'s `required_status_checks` |
| ENG-040.4 | `ci.yml`'s `deploy` job — `needs: [ci]`, `if:` restricts to `push` on `main` only |
| ENG-040.5 | This file itself — pipeline config is a committed, version-controlled YAML file |
| ENG-040.6 | `ci.yml` — every credential is `${{ secrets.* }}`, never hardcoded |
| ENG-010.2 | `branch-protection.json` — a protected branch with required checks/reviews blocks direct pushes |
| ENG-010.5 | `branch-protection.json`'s `required_status_checks` + `required_pull_request_reviews` |
| ENG-010.6 | Satisfied by GitHub's own default behaviour once `required_approving_review_count >= 1` — an author's own review never counts toward it; no separate config knob exists |
| ENG-010.7 | `branch-protection.json`'s `allow_force_pushes: false` |
| ENG-010.8 | Repository-level `delete_branch_on_merge` setting (see Usage) — a different API endpoint from branch protection itself |

## Prerequisites

- A GitHub repository under the `Socx-Org` organisation, with `main` as the default branch (`ENG-010.1`)
- **The repository must be public, or the account must have GitHub Pro** — confirmed for real, not documented anywhere before this round (see Design Decisions)
- CI-provider secrets already configured (`CI_DB_USER`, `CI_DB_PASSWORD`, `CI_DB_NAME`, `CI_DATABASE_URL`, and any application-specific ones) — provisioning them is `SEC-010`'s concern, not this file's
- `gh` CLI authenticated with `admin` access to the target repository, to apply branch protection
- A working CI workflow already merged to `main` and confirmed passing — see Usage step 6 for why this order matters

## Usage

Parameters: `{{ENVIRONMENT}}` (the deploy job's GitHub Environment name, per `OPS-010` tier).

1. Copy `workflows/ci.yml` to `.github/workflows/ci.yml` in the consuming repository, substituting `{{ENVIRONMENT}}`.
2. Adjust the `services.postgres` block: keep it for a project with a database to test against, remove it entirely otherwise (Expected Adaptations).
3. Configure the named secrets in the repository's own CI-provider secret store — never in the workflow file itself.
4. Apply branch protection:
   ```
   gh api repos/{{OWNER}}/{{REPO}}/branches/main/protection -X PUT --input branch-protection.json
   ```
5. Enable delete-on-merge (a separate, repository-level setting — not part of branch protection):
   ```
   gh api repos/{{OWNER}}/{{REPO}} -X PATCH -f delete_branch_on_merge=true
   ```
6. **Before applying branch protection, confirm `workflows/ci.yml` (adapted for the real project) is already merged to `main` and has run successfully at least once.** Applying `required_status_checks` referencing a check that has never run makes every future PR permanently unmergeable — found for real during `socx-platform`'s own application of this file (a `terraform`-not-installed failure was caught and fixed *before* protection was applied, not after).
7. Re-verify: open a PR and confirm the required check is actually required and blocks merge until passing; confirm a direct push to `main` is rejected (or, for a single-contributor repository using the `enforce_admins: false` adaptation, succeeds only via the explicit admin-bypass warning); confirm force-push to `main` is rejected. Record the method and date in this manifest's `verified` field.

## Expected Adaptations

**Consuming projects are expected to customise:**

- `{{ENVIRONMENT}}` and the deploy job's real steps (once `reference/deployment` exists)
- The `services.postgres` block — keep, remove, or replace with a different datastore per the project's actual dependencies
- Additional CI steps specific to one project (e.g. a separate lint/build pass for a Python worker, as `rms` has)

**Must remain unchanged to preserve compliance:**

- The `install → lint → test → build` order — reordering or skipping a stage breaks `ENG-040.2`'s fail-fast guarantee
- Secrets sourced only via `${{ secrets.* }}` — hardcoding one breaks `ENG-040.6`/`SEC-010.1`
- The deploy job's gating (`needs`, the `push`-to-`main`-only `if`) — loosening it breaks `ENG-040.4`
- `branch-protection.json`'s `allow_force_pushes: false` and required review count — loosening either needs a recorded `GEN-010.9` exception, or a permanent deviation needs an ADR (`DOC-020.2`)

## Related Documents

- Standards: `ENG-010`, `ENG-040`
- Architecture: none directly — this realises engineering process, not a target design
- ADRs: `ADR-150` (GitHub Actions), `ADR-170` (trunk-based development, branch protection)
- Current-State: `CS-TEC-010` (the real `rms`/`ghs` CI workflows this was grounded in and corrected against)
- Runbooks: none yet
- Automation: `reference/deployment` (real deploy steps, Deliverable 6.7, now landed); `.github/workflows/ci.yml` (socx-platform's own real, adapted CI — not a copy of `workflows/ci.yml` in this directory, since this repository has no Node/TS/Express application; see that file's own header comment)
- Exceptions: `docs/development/github-workflow.md` (`ENG-010.2`/`.5`, `GEN-010.9` — **closed 2026-08-07**, branch protection applied for real)

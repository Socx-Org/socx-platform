  a

# Engineering Standards Handbook

## Purpose

This handbook defines the **minimum** set of standards every SOCX project must follow. Full purpose, vision, and roadmap for the wider repository are in [docs/project/project-charter.md](../project/project-charter.md).

## Scope

A standard states *what* must be true. It does not restate:

- **how** a compliant implementation looks (that's a Reference Implementation)
- **why** a past decision was made (that's an ADR)
- **how to operate** something right now (that's a Runbook)
- **what** the target design is (that's Architecture documentation)

A standard MUST link to the relevant reference implementation, ADR, or template rather than duplicating its content.

## Separation of Concerns

| Concern                       | Lives in               | Answers                                    |
| ----------------------------- | ---------------------- | ------------------------------------------ |
| Standards                     | `docs/standards/`    | What every project MUST do                 |
| Reference Implementations     | `reference/`         | What a compliant implementation looks like |
| Architecture Decision Records | `docs/adr/`          | Why a specific decision was made           |
| Runbooks                      | `docs/runbooks/`     | How to operate / respond right now         |
| Architecture                  | `docs/architecture/` | What the target design is                  |

## Numbering Scheme

Each standard has a permanent ID: `<CATEGORY>-<NUMBER>`, e.g. `ENG-010`.

- Numbers start at `010` and increment by `10` within each category, leaving room to insert a new standard later (e.g. `ENG-015`) without renumbering anything already Approved and referenced elsewhere (ADRs, CI configs, onboarding docs).
- IDs are permanent once Approved. A superseded standard is marked `Deprecated` and points to its replacement — it is never renumbered or deleted, since other documents may already cite its ID.
- Requirements within a standard are sub-numbered (`ENG-010.1`, `ENG-010.2`, ...) so a specific rule can be cited precisely, e.g. in a CI failure message or code review comment.
- Filenames are ID-prefixed (`ENG-010-version-control.md`) so a directory listing is self-ordering and self-documenting.

## Categories

| Code | Category      | Scope                                                                         |
| ---- | ------------- | ----------------------------------------------------------------------------- |
| GEN  | General       | How the handbook itself works: lifecycle, exceptions, template usage          |
| ENG  | Engineering   | Source control, code quality, testing, CI/CD                                  |
| SEC  | Security      | Secrets management, dependency/vulnerability management, access control       |
| OPS  | Operations    | Environments, infrastructure as code, release/rollback, monitoring & alerting |
| DOC  | Documentation | What every project must document, and when an ADR is required                 |

## Table of Contents

| ID      | Title                                 | Status   |
| ------- | ------------------------------------- | -------- |
| GEN-010 | Standards Lifecycle & Governance      | Approved |
| ENG-010 | Version Control & Branching           | Approved |
| ENG-020 | Code Quality & Review                 | Approved |
| ENG-030 | Testing                               | Draft    |
| ENG-040 | CI/CD Pipelines                       | Draft    |
| SEC-010 | Secrets Management                    | Draft    |
| SEC-020 | Dependency & Vulnerability Management | Draft    |
| SEC-030 | Access Control                        | Draft    |
| OPS-010 | Environments & Promotion              | Planned  |
| OPS-020 | Infrastructure as Code                | Planned  |
| OPS-030 | Release & Rollback                    | Planned  |
| OPS-040 | Monitoring & Alerting                 | Planned  |
| DOC-010 | Required Project Documentation        | Planned  |
| DOC-020 | ADR Usage Criteria                    | Planned  |

Status is one of `Planned`, `Draft`, `Approved`, `Deprecated` — the authoritative status for a given standard is the `status` field in its own metadata, not this table; this column is kept in sync as a convenience index.

## Authoring a New Standard

1. Copy [templates/standards/standard-template.md](../../templates/standards/standard-template.md) into the appropriate category folder under `docs/standards/`.
2. Name it `<ID>-<slug>.md`.
3. Fill in the metadata block and body.
4. Add a row to the Table of Contents above.


# SOCX Platform Engineering Repository - Project Charter

## Purpose

The **socx-platform** repository is the engineering source of truth for the SOCX platform.

It is **not** an application repository.

It contains the standards, architecture, documentation, templates and operational guidance used across all SOCX applications.

Application source code remains in its own repositories (for example `socx-org-uk`, `ghs`, `rms`, `do-nginx-infra`).

---

# Vision

Create a reusable engineering platform that defines how every SOCX application is designed, deployed and operated.

The repository should become the canonical reference for:

* Engineering standards
* Architecture documentation
* Architecture Decision Records (ADRs)
* Deployment standards
* Operational runbooks
* Reusable templates
* Reference implementations
* Claude Code workflows

The repository should grow incrementally through reviewed deliverables rather than being generated all at once.

---

# Engineering Principles

The repository should follow these principles:

* Understand before changing.
* Prefer simplicity over unnecessary abstraction.
* Documentation is version controlled.
* Every directory has a single responsibility.
* Avoid duplicate sources of truth.
* Record significant decisions as ADRs.
* Build only what is currently needed (YAGNI).
* Review structure before creating content.

---

# Repository Structure

Current top-level structure:

```text
socx-platform/

├── .claude/
├── .github/
├── .vscode/

├── docs/
│   ├── adr/
│   ├── architecture/
│   ├── current-state/
│   ├── diagrams/
│   ├── onboarding/
│   ├── runbooks/
│   └── standards/

├── reference/
│
├── templates/
│
├── scripts/
│
├── examples/
│
├── README.md
├── CLAUDE.md
├── CONTRIBUTING.md
├── LICENSE
├── .editorconfig
├── .gitignore
└── SOCX.code-workspace
```

## Directory Responsibilities

| Directory              | Purpose                                                         |
| ---------------------- | --------------------------------------------------------------- |
| `docs/architecture`  | Target ("to-be") architecture                                   |
| `docs/current-state` | Existing ("as-is") environment                                  |
| `docs/adr`           | Architecture Decision Records                                   |
| `docs/runbooks`      | Operational procedures                                          |
| `docs/diagrams`      | Architecture and deployment diagrams                            |
| `docs/onboarding`    | Guides for new contributors                                     |
| `docs/standards`     | Engineering and deployment standards                            |
| `reference`          | Canonical reference implementations and approved configurations |
| `templates`          | Reusable starting points and boilerplate                        |
| `scripts`            | Automation scripts for maintaining the engineering platform     |
| `examples`           | Complete worked examples demonstrating standards and templates  |

---

# Repository Design Decisions

The following structural decisions have already been agreed:

* `platform/` was renamed to `reference/`.
* `docs/decisions/` was removed in favour of `docs/adr/`.
* There is a single top-level `scripts/` directory.
* `reference/` contains canonical implementations.
* `templates/` contains reusable starting points.
* `examples/` contains complete worked examples.
* `docs/current-state/` documents the existing environment.
* `docs/architecture/` documents the desired target architecture.
* `CLAUDE.md` should remain concise and define Claude's behaviour, not project-specific architecture.

---

# Deliverables

## Deliverable 1 — Repository Foundation ✅ Complete

Completed:

* Repository created
* Repository structure established
* README
* CLAUDE.md
* Initial documentation structure
* Repository review performed
* Structural refinements completed

Outcome:

A clean engineering platform ready to receive content.

---

## Deliverable 2 — Engineering Standards (Next)

Define the engineering handbook.

Topics are expected to include:

* Repository standards
* Directory standards
* Naming conventions
* Documentation standards
* ADR standards
* Git workflow
* Branching strategy
* Versioning
* Deployment standards
* Nginx standards
* systemd standards
* GitHub Actions standards
* Environment variables
* Port allocation
* Logging
* Monitoring
* Security
* Secrets management
* Backup strategy

The first task for Deliverable 2 is to agree the table of contents before writing any standards.

---

## Future Deliverables

3. Architecture Documentation
4. Architecture Decision Records
5. Claude Code Integration
6. Infrastructure Reference Assets
7. GitHub Standards
8. Diagram Library
9. Operational Runbooks
10. Automation Scripts
11. Reference Application
12. Production Readiness Review

---

# Working Method

For every deliverable:

1. Design the structure.
2. Review the structure.
3. Refine where necessary.
4. Create the content.
5. Review the content.
6. Commit the deliverable.

Avoid generating large amounts of documentation without first agreeing the structure.

---

# Long-Term Goal

The completed repository should function as the engineering handbook for the SOCX platform and serve as the authoritative reference for all future applications, infrastructure, and operational practices.

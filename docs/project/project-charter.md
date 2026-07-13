# SOCX Platform Engineering Repository – Project Charter

# Purpose

The **socx-platform** repository is the engineering source of truth for the SOCX platform.

It is **not** an application repository.

It contains the standards, architecture, templates, reference implementations, operational guidance and engineering assets that define how all SOCX applications are designed, built, deployed and operated.

Application source code remains in its own repositories (for example `socx-org-uk`, `ghs`, `rms`, and `platform-infra`).

---

# Vision

Create a reusable engineering platform that provides a consistent foundation for every SOCX project.

The repository serves as the canonical reference for:

* Engineering Standards
* Architecture Documentation
* Architecture Decision Records (ADRs)
* Current-State Documentation
* Operational Runbooks
* Reference Implementations
* Reusable Templates
* Automation & Tooling
* Claude Code workflows and engineering guidance

The repository evolves incrementally through reviewed and approved deliverables. Each deliverable becomes part of the long-term engineering knowledge base.

---

# Engineering Principles

The repository follows these principles:

* Understand before changing.
* Prefer simplicity over unnecessary abstraction.
* Documentation is version controlled.
* Every directory has a single responsibility.
* Avoid duplicate sources of truth.
* Record significant architectural decisions as ADRs.
* Build only what is currently needed (YAGNI).
* Review structure before creating content.
* Keep standards, architecture and implementation clearly separated.
* Documentation should be maintainable, traceable and reusable.

---

# Repository Structure

The repository structure is the authoritative organisation of the SOCX Engineering Platform.

The live repository tree is the source of truth for what exists. This document records **why** each directory exists rather than duplicating the filesystem.

## Directory Responsibilities

| Directory              | Purpose                                                         |
| ---------------------- | --------------------------------------------------------------- |
| `docs/architecture`  | Target ("to-be") platform architecture                          |
| `docs/current-state` | Current ("as-is") environment and deployment state              |
| `docs/standards`     | Engineering Standards Handbook                                  |
| `docs/adr`           | Architecture Decision Records                                   |
| `docs/runbooks`      | Operational procedures                                          |
| `docs/diagrams`      | Shared architecture, deployment and operational diagrams        |
| `docs/onboarding`    | Contributor onboarding guides                                   |
| `reference`          | Canonical reference implementations and approved configurations |
| `templates`          | Reusable templates and document scaffolding                     |
| `scripts`            | Automation supporting the engineering platform                  |
| `examples`           | Complete worked examples demonstrating standards and templates  |

---

# Repository Design Decisions

The following repository decisions have been approved:

* `reference/` contains canonical implementations.
* `templates/` contains reusable starting points.
* `examples/` contains complete worked examples.
* `docs/architecture/` documents the target platform architecture.
* `docs/current-state/` documents deployed reality.
* `docs/standards/` contains the Engineering Standards Handbook.
* `docs/adr/` records significant architectural decisions.
* `docs/runbooks/` contains operational procedures only.
* `docs/diagrams/` is the shared home for all diagrams.
* `CLAUDE.md` defines Claude Code behaviour and repository conventions, not platform architecture.

---

# Project Progress

The project is delivered incrementally through reviewed deliverables.

Every deliverable follows the same engineering workflow:

1. Design the structure.
2. Review the proposed structure.
3. Refine where necessary.
4. Produce the content.
5. Review the completed deliverable.
6. Approve and commit.

Large bodies of documentation are never generated before their structure has been agreed.

## Evolution of Delivery Plan

During execution, several originally planned deliverables were consolidated into broader engineering capabilities. For example, GitHub Standards became part of the Engineering Standards Handbook, Infrastructure Reference Assets and the Reference Application evolved into Reference Implementations, and Claude Code Integration became part of the repository foundation and engineering workflow. Conversely, Current-State Documentation was introduced as a dedicated deliverable to distinguish the deployed platform from the target architecture. This evolution reflects a more cohesive and maintainable engineering platform while preserving the intent of the original charter.

## Current Status

The table below records the current status of each deliverable. A deliverable is considered **Complete** once it has successfully passed technical review, received formal approval, and been committed to the repository.

## Current Status

| Deliverable                                           | Status      | Version | Baseline               |
| ----------------------------------------------------- | ----------- | ------- | ---------------------- |
| Deliverable 1 – Repository Foundation                | ✅ Complete | 1.0     | `v0.1-foundation`    |
| Deliverable 2 – Engineering Standards Handbook       | ✅ Complete | 1.0     | `v0.2-standards`     |
| Deliverable 3 – Architecture Documentation           | ✅ Complete | 1.0     | `v0.3-architecture`  |
| Deliverable 4 – Current-State Documentation          | ✅ Complete | 1.0     | `v0.4-current-state` |
| Deliverable 5 – Architecture Decision Records (ADRs) | 🚧 In Progress | —      | —                     |
| Deliverable 6 – Reference Implementations            | ⏳ Planned  | —      | —                     |
| Deliverable 7 – Operational Runbooks                 | ⏳ Planned  | —      | —                     |
| Deliverable 8 – Automation & Tooling                 | ⏳ Planned  | —      | —                     |
| Deliverable 9 - Production Readiness Review           | ⏳ Planned  | —      | —                     |

---

# Deliverables

## Deliverable 1 – Repository Foundation ✅ Complete

### Objective

Establish the repository structure and engineering conventions that will support the SOCX Engineering Platform.

### Outcome

Completed:

* Repository structure
* Documentation framework
* README
* CLAUDE.md
* Supporting templates
* Repository review and refinement

Result:

A clean engineering platform ready to receive structured content.

---

## Deliverable 2 – Engineering Standards Handbook ✅ Complete

### Objective

Define the minimum engineering, security, operational and documentation standards that every SOCX project must follow.

### Outcome

The Engineering Standards Handbook has been established under `docs/standards/`.

The handbook includes:

* General Governance (GEN)
* Engineering Standards (ENG)
* Security Standards (SEC)
* Operational Standards (OPS)
* Documentation Standards (DOC)

Supporting assets include:

* Standards Handbook
* Numbering scheme
* Standard lifecycle
* Standard template
* Cross-references to Architecture, ADRs, Runbooks and Reference Implementations

---

## Deliverable 3 – Architecture Documentation ✅ Complete

### Objective

Define the target ("to-be") architecture of the SOCX platform.

### Outcome

The Architecture Handbook has been established under `docs/architecture/`.

The architecture currently covers:

* CTX – Platform Context
* DOM – System Landscape
* APP – Application Architecture
* DAT – Platform Data Architecture
* INT – Integration Architecture
* TEC – Approved Technology Stack
* INF – Target Infrastructure Topology
* IAM – Identity, Trust & Security Architecture

Supporting assets include:

* Architecture Handbook
* Architecture document template
* Document lifecycle
* Cross-references to Engineering Standards, ADRs, Reference Implementations, Runbooks and Current-State documentation

The Architecture Documentation defines the intended platform design only. It deliberately avoids implementation details, operational procedures and current deployment state.

---

## Deliverable 4 – Current-State Documentation ✅ Complete

### Objective

Document the current ("as-is") state of the SOCX platform, providing an authoritative and evidence-based inventory of the deployed environment.

### Outcome

The Current-State Documentation framework has been established under `docs/current-state/` using a modular, one-concept-per-document structure that mirrors the Architecture Documentation.

The documentation currently covers:

* Current Platform Context
* Current System Landscape
* Current Application Inventory
* Current Data Inventory
* Current Integration Inventory
* Current Technology Inventory
* Current Infrastructure Inventory
* Current Identity & Access Inventory
* Repository Inventory

Supporting assets include:

* Current-State Handbook (`docs/current-state/README.md`)
* Current-State document template
* Document lifecycle and metadata model
* Provenance and confidence model for observed facts
* Gap analysis against the target architecture
* Cross-references to Architecture Documentation, Engineering Standards, ADRs, Reference Implementations and Runbooks

The Current-State Documentation records observed facts only. It deliberately avoids defining target architecture, operational procedures or engineering policy, instead linking to the appropriate Architecture Documentation, Engineering Standards, Runbooks and ADRs where applicable.

Together with the Engineering Standards Handbook and Architecture Documentation, it provides a complete baseline for planning, implementing and validating future changes to the SOCX platform.

---

## Deliverable 5 – Architecture Decision Records (ADRs) **🚧** In Progress

### Objective

Capture the significant engineering and architectural decisions that shape the SOCX platform.

### Expected Outcome

Establish a maintained collection of ADRs explaining why major technical decisions were made, with traceability to the Engineering Standards and Architecture Documentation.

---

## Deliverable 6 – Reference Implementations

### Objective

Provide canonical implementations demonstrating how the Engineering Standards and Architecture Documentation are realised.

### Expected Outcome

Reference implementations covering infrastructure, deployment, CI/CD, security and application patterns that new projects can adopt as the approved baseline.

---

## Deliverable 7 – Operational Runbooks

### Objective

Document the operational procedures required to deploy, operate, monitor and recover the platform.

### Expected Outcome

A comprehensive set of runbooks covering routine operations, incident response, deployment, rollback, maintenance and disaster recovery.

---

## Deliverable 8 – Automation & Tooling

### Objective

Provide reusable automation supporting development, deployment and platform maintenance.

### Expected Outcome

Automation scripts, reusable tooling and engineering utilities that reduce manual effort and improve consistency across all SOCX projects.

---

# Long-Term Goal

The completed **socx-platform** repository will provide the governance, standards, architecture, current-state inventories, reference implementations, operational guidance and automation that define how the SOCX platform is engineered.

The completed deliverables establish the engineering foundation by documenting:

* how the platform is governed (Engineering Standards),
* what the platform is intended to become (Architecture),
* and what is deployed today (Current-State Documentation).

Future deliverables will build upon this foundation by capturing architectural decisions, providing canonical reference implementations, documenting operational procedures, and automating engineering workflows.

The repository will serve as the authoritative engineering handbook for all current and future SOCX applications, enabling consistent design, implementation, deployment and operation across the platform.

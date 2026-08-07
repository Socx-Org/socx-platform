---
id: ENG-070
title: Development Workflow
category: Engineering
status: Approved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.0"
last_reviewed: 2026-08-08
review_cycle: annual
related:
  adrs:
    - ADR-190
  reference:
    - reference/github
  templates:
    - templates/github
supersedes: []
superseded_by: null
---
# ENG-070 — Development Workflow

## Scope

Applies to how work is planned, tracked, and executed in every SOCX project repository: issue creation and classification, Status tracking, Definition of Ready / Definition of Done, ADR-escalation for Epics, and the boundary between application-specific work and platform-level change.

Does not cover branch and commit mechanics (see `ENG-010`), the substance of code review (see `ENG-020`), or CI/CD pipeline stages (see `ENG-040`) — this standard governs the process work moves through, not the mechanics of git, review content, or pipeline configuration. The step-by-step operational walkthrough of this process is `docs/development/github-workflow.md`; this standard states the requirements it must satisfy.

## Rationale

Without one authoritative definition, each project repository tends to reinvent its own tracking conventions — different Status values, different issue structures, different rules for when an architectural decision needs to be escalated. This was observed directly during the first weeks of the SOCX Application Modernisation programme: three different Status-field models and two different commit conventions existed simultaneously across two repositories (see `ADR-190`). A single, referenced standard prevents this drift without requiring every repository to maintain its own copy of the rules.

## Requirements

1. `ENG-070.1` — No implementation work MUST begin without a corresponding, already-created GitHub Issue. An idea, bug report, or task MUST become an Issue before any code, configuration, or documentation change is made for it.
2. `ENG-070.2` — Every project repository MUST classify work using GitHub's native Issue Types (`Epic`, `Feature`, `Task`, `Bug`, `Spike`) as the primary classification, not labels. Labels MAY be used for cross-cutting concerns (e.g. component/area) but MUST NOT duplicate the Issue Type.
3. `ENG-070.3` — Application-development work MUST use the five-state Status workflow: `Backlog` → `Ready` → `In Progress` → `In Review` → `Done`. "Application-development work" means any project other than `socx-platform`'s own platform-governance/deliverable tracking (Project #1), which retains its own three-state model (`Todo`/`In Progress`/`Done`) as a deliberate, documented exception — not an oversight. A "blocked" condition MUST be tracked as a field or flag orthogonal to Status, not as a Status value itself, so a blocked item retains its real stage.
4. `ENG-070.4` — An item MUST NOT move to `Ready` or `In Progress` until its Definition of Ready is satisfied:
   - written acceptance criteria exist;
   - the item's ADR Status (see `ENG-070.6`) is not `New ADR Required` — i.e. any architectural dependency is resolved or explicitly accepted as non-blocking;
   - identified blocking dependencies are either resolved or explicitly accepted by the accountable lead;
   - there is no open question requiring a decision from the accountable architect or lead.
5. `ENG-070.5` — An item MUST NOT move to `Done` until its Definition of Done is satisfied:
   - tests pass for real (executed, not merely written);
   - documentation is updated in the same change, not deferred;
   - no new violation of `SEC-010` is introduced;
   - compliance with the ADRs and Standards the item depends on is confirmed;
   - the relevant runbook is updated where the change is operationally significant.
6. `ENG-070.6` — Every Epic MUST state which ADRs it depends on, and MUST explicitly assess whether implementing it requires a new or amended ADR before work begins. This assessment MUST be tracked as an explicit value — `No ADR Needed` / `Existing ADR Sufficient` / `New ADR Required` / `ADR Drafted` / `ADR Approved` — and MUST NOT be left implicit or inferred from the issue body.
7. `ENG-070.7` — Improvements to the SOCX Engineering Platform itself (new or amended ADRs, Standards changes, reference-implementation updates, runbooks, or platform tooling) that arise from application-specific work MUST be tracked separately from the application work that surfaced them, under the platform's Platform Evolution mechanism, and implemented in `socx-platform`'s own repository under its own governance — not folded into the application repository's Epic.
8. `ENG-070.8` — Every commit and pull request MUST reference the Issue it implements, per `ENG-010.4`'s commit format. Closing an Issue MUST cite the commit or pull request that resolved it.
9. `ENG-070.9` — This standard's authoritative text, and the operational workflow document it governs (`docs/development/github-workflow.md`), live in `socx-platform` and MUST be referenced, not duplicated, by every other SOCX project repository. A project-specific `CLAUDE.md` or equivalent instruction file MUST contain only genuinely project-specific context and a pointer to this standard — never a restated copy of it.

## Exceptions

Per `GEN-010.9`–`GEN-010.10`. Project #1's retained three-state Status model (`ENG-070.3`) is a recorded design decision, not an exception requiring separate documentation — this standard defines it as the correct model for that project's kind of work.

## Related

- Reference implementation(s): `reference/github`
- ADR(s): `ADR-190`
- Template(s): `templates/github`

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-08-08 | Initial draft | Socx   |
| 1.0     | 2026-08-08 | Approved      | Socx   |

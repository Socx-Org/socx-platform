---
id: ADR-190
title: Standardised development workflow across SOCX repositories
status: Approved
category: Engineering Process
version: "1.0"
date: 2026-08-08
deciders: Platform Engineering
related:
  architecture: []
  standards:
    - ENG-070
    - ENG-010
  current_state: []
  reference:
    - reference/github
  runbooks: []
  adrs:
    - ADR-170
supersedes: []
superseded_by: null
---

# ADR-190 — Standardised development workflow across SOCX repositories

## Context

The SOCX Application Modernisation programme began application-repository work (RMS first) reusing conventions carried informally from `socx-platform`'s own authoring practice, rather than from a written, portable standard. Within the first weeks this produced real, observed drift:

- Three different Status-field models existed simultaneously: Project #1's three states (`Todo`/`In Progress`/`Done`), Project #2's five states (`Backlog`/`Ready`/`In Progress`/`In Review`/`Done`), and a four-state model drafted from an ambiguous reading of the platform owner's own example — later explicitly rejected.
- Two different commit-message conventions existed: `socx-platform`'s issue-number-prefixed header (`#<issue> type(scope): summary`, defined operationally in `docs/development/github-workflow.md`) and a plain Conventional Commits header with a trailing issue reference used for the first RMS commits.
- `ENG-010.4` and `docs/development/github-workflow.md` disagreed with each other on the commit format both were supposed to define.
- `templates/github/` is cited by `ENG-010`, `ENG-020`, `ENG-050`, `ENG-060`, and `DOC-010` as the canonical source of issue and pull-request templates, but was empty.
- No `.github/ISSUE_TEMPLATE/` existed in any repository, and no AI-specific ADR or Engineering Standard existed — only an informal `CLAUDE.md` and the operational workflow document, both written for `socx-platform` alone.

None of this was a policy disagreement — it was the predictable result of every new application repository (RMS now, GHS and AMS later) inheriting process by imitation rather than by reference to one written standard.

## Decision

Adopt a single, referenced source of truth for how work is planned, tracked, and executed across every SOCX repository, expressed as five artefacts:

1. **`ENG-070` — Development Workflow** — a new Engineering Standard stating the formal, numbered requirements: issue-before-implementation, the five-state Status workflow for application-development work, Definition of Ready / Definition of Done, the ADR-escalation mechanism for Epics, and the boundary between application-specific work and Platform Evolution work.
2. **`ENG-010.4` amended** — the commit-format rule is corrected in place, in the standard that already owns it, rather than left to disagree with the operational document.
3. **`docs/development/github-workflow.md` generalised** — rewritten from a `socx-platform`-specific runbook into the shared operational "how" that every SOCX repository follows *by reference*, while remaining the literal document `socx-platform` itself follows for its own (Project #1, three-state) work.
4. **`templates/github/` populated** — canonical issue-body templates (Epic, Feature, Task, Bug, Spike) and the canonical pull-request template, reconciling the two ad hoc issue structures used so far into one.
5. **Repository-specific `CLAUDE.md` files stay minimal everywhere** — pointing at `ENG-070` and `github-workflow.md`, never restating them. (Creating or copying these into RMS/GHS/AMS is explicitly deferred to a separate, later piece of work — see Consequences.)

Project #1 (`socx-platform`'s own governance/deliverable tracking) keeps its distinct three-state Status model; the five-state model is scoped to application-development work — any `Product: RMS/GHS/AMS` item, and Platform Evolution items, in Project #2. This split is deliberate, not an oversight: platform governance and application delivery are different kinds of work, and forcing one Status model onto both was rejected by the platform owner directly.

## Alternatives Considered

- **Let each application repository's workflow evolve independently.** Rejected: this is precisely the failure mode this ADR exists to correct — it had already produced three divergent Status models and two commit conventions within a single programme, weeks apart.
- **Copy the standard's full text into each application repository, kept in sync by automation.** Rejected: still produces N copies that can drift; a pointer to one canonical source is simpler, requires no sync tooling, and matches how `reference/` implementations are already treated — canonical master, consumed by reference, not duplicated.
- **One Status model for every GitHub Project, including Project #1.** Rejected, per explicit platform-owner direction: platform-governance tracking and application-development delivery are genuinely different in shape (documentation-and-decision work vs. multi-stage delivery with review), and a shared five-state model would misrepresent Project #1's simpler reality rather than clarify it.

## Consequences

- `ENG-010.4` changes for the first time since its original approval (`v1.2`) — a real, visible amendment recorded in its own revision history, not a silent reinterpretation.
- Every future SOCX application repository inherits this workflow by pointing at `socx-platform`'s `ENG-070` and `github-workflow.md`, not by copying files into its own tree — this requires the discipline of actually following the pointer each session; it is not mechanically enforced by GitHub across repositories.
- `templates/github/` moves from a cited-but-empty directory (a real gap present since the Engineering Standards were first written) to a populated, canonical source. GitHub's issue- and pull-request-template mechanisms require the functioning copy to physically exist inside each consuming repository (`.github/ISSUE_TEMPLATE/`, `.github/PULL_REQUEST_TEMPLATE.md`) — there is no cross-repository inheritance GitHub itself provides — so `templates/github/` is the canonical definition to copy from, matching how every other `templates/` subdirectory in this repository already works.
- `socx-platform`'s own `.github/ISSUE_TEMPLATE/` is populated from these templates as part of this same change, since it is `templates/github/`'s first real consumer.
- Propagating `.github/ISSUE_TEMPLATE/` and a repository-specific `CLAUDE.md` into RMS, GHS, and AMS is **explicitly deferred** — a separate, later piece of work once this standard exists and is Approved, per the platform owner's own stated constraint. This ADR creates the standard to point at; it does not itself change any other repository.

## Related Documents

- Standards: `ENG-070` (new), `ENG-010` (amended)
- ADRs: `ADR-170` (the branching/commit decision `ENG-010.4`'s amendment stays consistent with)
- Reference Implementations: `reference/github` (unaffected by this change)
- Templates: `templates/github` (populated as a direct result of this decision)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-08-08 | Initial draft | Socx   |
| 1.0     | 2026-08-08 | Approved      | Socx   |

---
id: GEN-010
title: Standards Lifecycle & Governance
category: General
status: Approved
applies_to: All SOCX projects
owner: Platform Engineering
version: "1.1"
last_reviewed: 2026-07-11
review_cycle: annual
related:
  adrs:
    - ADR-010
    - ADR-020
    - ADR-030
  reference: []
  templates:
    - templates/standards/standard-template.md
supersedes: []
superseded_by: null
---

# GEN-010 — Standards Lifecycle & Governance

## Scope

Applies to every document under `docs/standards/`, including this one. Defines how a standard is proposed, reviewed, approved, revised, deprecated, and how exceptions are requested.

Does not define the content of any specific engineering, security, operations, or documentation standard — see the relevant category for that.

## Rationale

Standards are only useful if they can be trusted to reflect what's actually required, right now. That trust depends on a predictable, low-ceremony process for how a standard comes into existence, changes, and eventually retires — otherwise standards drift out of sync with practice, or accumulate without review. This standard exists so that process doesn't need to be re-derived or re-argued every time a new standard is proposed.

## Requirements

1. `GEN-010.1` — A new standard MUST begin life with `status: Draft` and `version: "0.1"`.
2. `GEN-010.2` — A Draft standard MUST be authored from `templates/standards/standard-template.md` and MUST be assigned the next unused ID in its category (the previous ID plus 10).
3. `GEN-010.3` — A Draft standard MUST be explicitly reviewed and approved before its `status` changes to `Approved`. Approval sets `version` to `"1.0"`.
4. `GEN-010.4` — Once `Approved`, a standard's `id` MUST NOT be reused, renumbered, or deleted, even after it is later deprecated.
5. `GEN-010.5` — Any revision to an Approved standard MUST increment `version` (a minor increment for clarifying edits that don't change a requirement's meaning; a major increment when a requirement's meaning changes) and MUST add a row to the Revision History table.
6. `GEN-010.6` — A revision that changes the meaning of an existing requirement MUST update `last_reviewed` and SHOULD call this out in the pull request description, so projects relying on the previous meaning can re-assess compliance.
7. `GEN-010.7` — A standard MUST be reviewed at least once per its stated `review_cycle`, even when no content changes are needed. A no-change review still updates `last_reviewed`.
8. `GEN-010.8` — A standard that is replaced MUST be marked `status: Deprecated` and MUST set `superseded_by` to the replacing standard's ID. It MUST remain in place rather than being deleted, since other documents may still cite its ID. The replacing standard MUST set `supersedes` accordingly.
9. `GEN-010.9` — A project MAY request an exception to a specific requirement. The exception MUST be recorded in that project's own repository (not in this handbook), MUST cite the specific requirement ID (e.g. `ENG-010.2`), MUST state the reason and a review or expiry date, and SHOULD be linked from the project's README or onboarding documentation.
10. `GEN-010.10` — Exceptions MUST NOT be used to silently avoid a requirement. An undocumented deviation from an Approved standard is a compliance gap, not an exception.

## Exceptions

This standard defines the exception process (`GEN-010.9`–`GEN-010.10`) used by every other standard in the handbook. Because it is foundational governance rather than a project-level requirement, `GEN-010` itself may only be excepted by a recorded ADR explaining why the lifecycle process does not apply — not by the lightweight per-project exception mechanism it defines for other standards.

## Related

- Reference implementation(s): none
- ADR(s): `ADR-010`, `ADR-020`, `ADR-030`
- Template(s): `templates/standards/standard-template.md`

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | 2026-07-11 | Initial draft | |
| 1.0 | 2026-07-11 | Approved | |
| 1.1     | 2026-07-14 | Added ADR cross-references | Socx   |

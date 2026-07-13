---
id: ADR-030
title: Documentation-first engineering philosophy
status: Draft
category: Platform & Governance
version: "0.1"
date: 2026-07-14
deciders: Platform Engineering
related:
  architecture: []
  standards:
    - GEN-010
    - DOC-010
  current_state: []
  reference: []
  runbooks: []
  adrs:
    - ADR-010
    - ADR-020
supersedes: []
superseded_by: null
---

# ADR-030 — Documentation-first engineering philosophy

## Context

A platform meant to bring consistency across many applications can be built two ways: code-first, with documentation catching up afterwards, or documentation-first, with governing documentation produced before the code it governs. SOCX chose the latter, and in a deliberate order. This ADR records that choice and the ordering, which together explain the shape of the whole deliverable roadmap.

## Decision

The platform is developed **documentation-first**, in the order **Engineering Standards → Architecture → Current-State → Implementation**:

1. **Standards** (what every project MUST do) are established first.
2. **Architecture** (the target design) is defined against those standards.
3. **Current-State** (what is actually deployed) is inventoried so the target is never confused with reality.
4. **Implementation** (reference implementations, runbooks, automation, and application code) follows.

Governing documentation precedes the code it governs, and each deliverable is designed, reviewed, and approved before its content is generated (per the charter's engineering workflow). Large bodies of documentation are never generated before their structure is agreed.

## Alternatives Considered

- **Code-first, document afterwards** — Rejected: the platform's entire purpose is consistency across many applications; without standards and architecture first, each application re-decides independently and the documentation degrades into archaeology of choices already made (exactly what `CS-TEC-010` and `CS-IAM-010` found — divergent, undocumented per-app decisions).
- **Current-State only, no target architecture** — Rejected: an as-is inventory with no to-be design gives nothing to converge on.
- **Big-bang generation of all documentation at once** — Rejected: violates the review-before-content principle; unreviewed large-scale document generation is the charter's explicit anti-pattern.

## Consequences

- Early deliverables (Standards, Architecture) are usable before any reference code exists.
- Current-State is a first-class deliverable, which is what surfaced the platform's real footprint and its gaps (a fourth app, no non-production tier, unverified backups).
- The approach front-loads decisions — which is precisely why this ADR log exists: front-loaded decisions need durable, citable rationale.
- Documentation can outrun implementation; this is mitigated by Current-State's shorter review cycle and by treating reference implementations and runbooks as their own deliverables.

## Related Documents

- Architecture: none directly — this philosophy shapes the order in which architecture is produced, rather than any single design
- Standards: `GEN-010` (handbook governance), `DOC-010` (required project documentation)
- Current-State documentation: none
- Reference Implementations: none
- Runbooks: none
- ADRs: `ADR-010` (decisions recorded as ADRs), `ADR-020` (the governance structure this philosophy populates)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-07-14 | Initial draft | Socx   |

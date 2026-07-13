---
id: ADR-<NUMBER>                   # e.g. ADR-010 — permanent once Approved; never reused or renumbered. Increments of 10.
title: <Decision Title>
status: Draft                      # Draft | Approved | Superseded | Deprecated | Rejected
category: <Platform & Governance | Infrastructure | Application | Data | Integration | Security & Identity | Operations | Engineering Process>
version: "0.1"                     # editorial revision only — a decision reversal is a NEW superseding ADR, never an edit (see DOC-020.5)
date: YYYY-MM-DD                   # date the current status was reached
deciders: <role, e.g. Platform Engineering>
related:
  architecture: []                 # Architecture documents this decision shapes, e.g. INF-010
  standards: []                    # Engineering Standards this decision supports, e.g. OPS-010
  current_state: []                # docs/current-state/ evidence informing the decision, e.g. CS-TEC-010
  reference: []                    # reference/ implementations that realize it
  runbooks: []                     # operational procedures for it
  adrs: []                         # related, superseding, or superseded ADRs
supersedes: []
superseded_by: null
---
# <ID></id> — <Decision Title></decision>

## Context

The forces that make a decision necessary: the problem, the constraints, and any evidence (link the `CS-*` current-state finding where the reality is already observed). State the situation neutrally — do not pre-argue the choice here.

## Decision

The choice made, stated plainly in the active voice ("The platform will …"). For a `Draft` ADR whose decision is not yet ratified, say so explicitly and mark any proposed direction as a recommendation pending sign-off — never assert an unmade decision as settled.

## Alternatives Considered

Each option that was genuinely weighed, and why it was or wasn't chosen. This is the home for the reasoning a `Rejected` option deserves. One sub-heading or row per alternative.

## Consequences

What becomes easier, harder, or constrained as a result — positive and negative. Include follow-on work the decision creates and anything it explicitly defers.

## Related Documents

- Architecture:
- Standards:
- Current-State documentation:
- Reference Implementations:
- Runbooks:
- ADRs (supersedes / superseded by / related):

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | YYYY-MM-DD | Initial draft |        |

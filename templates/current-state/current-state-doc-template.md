---
id: <CS-CATEGORY-NUMBER or REP-NUMBER>   # e.g. CS-CTX-010 or REP-010 — permanent once Approved; never reused or renumbered
title: <Document Title>
category: <Context | Domain | Application | Data | Integration | Technology | Infrastructure | Identity | Repository>
status: Draft                      # Draft | Approved | Deprecated
gap_status: Not yet assessed        # Not yet assessed | Aligned | Diverges | N/A — no architecture counterpart (REP-010 only)
confidence: Low                    # High | Medium | Low — how sure we are the Inventory section is accurate
owner: <role, e.g. Platform Engineering>
version: "0.1"
last_reviewed: YYYY-MM-DD           # the date these facts were last confirmed against reality
review_cycle: quarterly
related:
  architecture: []                  # target architecture document(s) this is compared against — leave empty for REP-010
  standards: []
  adrs: []
  reference: []
  runbooks: []
supersedes: []
superseded_by: null
---

# <ID> — <Title>

## Scope

What this inventory covers, and what it explicitly does not — including which other document(s) own anything adjacent. State plainly that this records facts, not intentions, and never operational procedure (see the handbook's Runbook boundary).

## Method

How these facts were gathered — e.g. "observed via SSH on <date>", "read from `<config file>` on <date>", "reported by <source>". Provenance is what makes an inventory trustworthy; an unverified claim should be reflected in `confidence: Low`, not omitted.

## Inventory

The actual facts, as tables. Concrete detail (hostnames, versions, ports, account names) belongs here. Where a table's rows come from more than one source, add a `Source` column per row (as `CS-TEC-010` does) rather than relying on the document-level `Method` section alone.

## Gap vs. Target Architecture

| Aspect | Current State | Target (cite ID only) | Difference | Impact |
|---|---|---|---|---|

Cite the target architecture document by ID only — never reproduce its diagram, table, or prose here. For a document with no architecture counterpart (`REP-010`), omit this section and replace it with a one-line note: "No architecture counterpart — this is a stand-alone engineering-governance inventory."

## Related Documents

- Architecture:
- Standards:
- ADRs:
- Reference Implementations:
- Runbooks:

## Revision History

| Version | Date | Change | Author |
|---|---|---|---|
| 0.1 | YYYY-MM-DD | Initial draft | |

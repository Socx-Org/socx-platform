---
id: APP-020
title: Configuration Management Pattern
category: Application
status: Approved
owner: Platform Engineering
version: "1.0"
last_reviewed: 2026-08-08
review_cycle: annual
related:
  standards: []
  adrs: []
  reference: []
  runbooks: []
  current_state: []
supersedes: []
superseded_by: null
---

# APP-020 — Configuration Management Pattern

## Scope

A pattern for **runtime-mutable, administrator-facing settings** — values an operator changes while the application keeps running, without a restart or redeploy. This is deliberately narrower than, and does not change, `APP-010`'s existing principle that startup configuration and secrets are read once and passed down. The two are different classes of value with different lifecycles: a database connection string is fixed for a process's lifetime; whether public self-registration is currently open is not.

**Status note, stated explicitly because it matters:** this document records a real, working pattern — not a mandatory standard every application must adopt. It is a **Platform Pattern**, not yet a **Shared Platform Asset**: the programme's own graduation criterion (validated across at least two real applications) is not met. RMS is currently the only application live on the platform. This document exists so `ghs`/`ams`, once rebuilt, have a real example to adopt or deliberately diverge from — not to mandate anything yet.

## Context

Flagged early in the SOCX Application Modernisation programme's own governance design as a candidate for a new ADR, then never actually written up. RMS's real implementation surfaced during Platform Alignment discovery (2026-08-08): a `system_settings` table, read live by both its Node API (via Prisma) and its Python worker (via raw SQL) — genuinely cross-language, cross-process shared configuration, validated in real production use, not hypothetical.

## Target Design

- A single key/value table (`key` primary key, `value`, `description`, `updated_at`, `updated_by`) holding settings intended to be changed by an administrator at runtime.
- **Read live, at the point of use, every time** — not cached, not read once at startup. This is the entire point: a change takes effect on the next read, with no restart. RMS's dispatch engine, for example, re-reads its own poll interval every loop iteration.
- **Every consuming runtime reads the same table directly** — not through a shared library or service, just the same underlying rows, each runtime's own idiomatic query mechanism (an ORM call, a raw `SELECT`). This works because every consumer already shares the same database (`ADR-080`'s single-writer-per-domain model doesn't apply here — this is intra-application configuration, not cross-system data).
- **Changes go through an authenticated, validated admin interface** — not direct database writes. Each setting's valid values are checked at the point of change (e.g. a boolean-only setting rejects anything but `"true"`/`"false"`; a numeric setting is range-checked), not left to whatever a client happens to send.
- **A setting's description is stored alongside its value**, in the same row — self-documenting for whoever is looking at the table directly, not dependent on separate, driftable documentation.

## What this pattern is not for

Secrets (`SEC-010`, `ADR-130` — those go through systemd credentials, never this table). Configuration that's fixed per-deployment and doesn't need to change without a redeploy (`APP-010`'s existing "read once, passed down" principle already covers that case correctly). Cross-application data of any kind (`ADR-080`).

## Current-State Gap

Validated in one real application (RMS). Not yet assessed against `ghs`/`ams`, which don't have real, rebuilt implementations yet to check against.

## Related Documents

- Architecture: `APP-010` (the startup-configuration principle this pattern deliberately doesn't change)
- ADRs: `ADR-080` (why this isn't cross-system data)
- Reference Implementations: none yet — RMS's own `system_settings` table and `admin.js`/`db.py` are the real, current example; a `reference/application` addition is a future candidate once a second real application validates this pattern
- Current-State: none yet

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-08-08 | Initial draft | Socx   |
| 1.0     | 2026-08-08 | Approved      | Socx   |

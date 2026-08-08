---
id: ADR-200
title: Data-access approach — raw SQL over an ORM, platform default
status: Approved
category: Data
version: "1.0"
date: 2026-08-08
deciders: Platform Engineering
related:
  architecture:
    - DAT-010
  standards:
    - ENG-050
    - ENG-060
  current_state:
    - CS-TEC-010
  reference:
    - reference/application
  runbooks: []
  adrs:
    - ADR-090
    - ADR-070
    - ADR-060
supersedes: []
superseded_by: null
---

# ADR-200 — Data-access approach: raw SQL over an ORM, platform default

## Context

`ADR-090` approved PostgreSQL as the platform's primary datastore but explicitly deferred the data-access approach — *"standardise on Prisma... versus the raw `pg` driver... versus permitting both... is deferred to a dedicated future ADR."* This is that ADR.

`CS-TEC-010` (current-state inventory) confirms real, already-existing divergence: `ghs` (legacy) uses the raw `pg` driver, no ORM; `rms` (live in production) uses Prisma; `ams` (legacy) uses "its own Prisma-style `packages/db`" — not deeply inspected. This is exactly the silent-divergence risk `ADR-090`'s own Context section named as the platform's biggest data risk.

`reference/application` — the platform's canonical three-layer service (`ADR-060`), Approved and verified on-host — demonstrates raw `pg` behind a repository pattern (`WidgetsRepository`, a narrow interface the application layer depends on, never `pg` or SQL directly). Its own `schema.sql` explicitly notes the migration-*tool* question is also deferred by `ADR-090`, applied "however the consuming project already manages migrations." Neither the ORM question nor the migration-tool question was ever actually settled — both were left open by the same deferral.

RMS, the only application currently live in production, uses Prisma for its API's data access and raw SQL via SQLAlchemy Core (not a real ORM — no model classes, just `text()` queries) for its Python worker. No automated Prisma migration history exists; the real schema source of truth is hand-maintained SQL files (`infra/rms_00*.sql`), applied via `psql`/`apply-migration.sh`, with `schema.prisma` manually kept in sync.

`ADR-070` already carves out RMS's Python worker as *"an explicit, bounded exception — a scheduled-work runtime — not a second general-purpose application stack."* This matters directly here: Prisma has no meaningful Python story, so no platform-wide "standardise on Prisma" decision could ever actually cover every runtime the platform already runs — a single-ORM-everywhere standard was never fully achievable regardless of preference.

## Decision

The platform's data-access default is **raw SQL via a lightweight driver** — `pg` for Node/TypeScript, `psycopg2`/SQLAlchemy Core for Python — accessed only through a **repository pattern** behind the data-access layer (`ADR-060`), matching `reference/application`'s demonstrated, Approved pattern. This is the default for **new** application data-access work.

No specific migration tool is mandated. Every application MUST maintain its schema as versioned, applied-in-order SQL migration files, applied via whatever mechanism it already uses (`psql`, a small runner script, or a future shared tool). A real, working convention satisfies this; adopting a specific migration tool with no evidenced need for one is not required.

This does **not** require migrating RMS's existing, live Prisma usage. RMS may continue using Prisma for its API; this is a recorded, deliberate exception, not a violation requiring remediation. A future, larger structural rewrite of RMS is a reasonable opportunity to align at that time — not a debt owed separately.

GHS and AMS, not yet rebuilt, adopt this default as part of their own upcoming Foundation-phase work, at zero migration cost.

## Alternatives Considered

- **Standardise on Prisma platform-wide** — Rejected: Prisma has no meaningful Python story, so it could never cover the Python worker runtime `ADR-070` already carves out as a standing exception — a "platform standard" that structurally cannot apply to every runtime undermines its own purpose. Also contradicts `reference/application`'s own demonstrated, Approved pattern.
- **Standardise on raw SQL platform-wide and require RMS to migrate off Prisma immediately** — Rejected: RMS is the only application currently live in production. Forcing a real, disruptive migration to satisfy a documentation preference, with no functional defect being fixed, is exactly the premature-work this platform's own discipline argues against elsewhere.
- **Explicitly permit both indefinitely, no default** — Rejected: this is what `ADR-090` already observed producing real, silent divergence (`CS-TEC-010`'s finding). A default with a narrow, explicit, recorded exception for RMS's specific circumstance is more honest than "anything goes," without forcing unnecessary work.
- **Mandate a specific migration tool** (e.g. `node-pg-migrate`, Flyway) — Rejected: no evidenced need beyond what a small, versioned SQL-file convention already provides; matches `reference/application`'s own explicit deferral of this exact question.

## Consequences

- GHS and AMS's own Foundation-phase work adopts raw SQL + repository pattern from the start, at zero migration cost — this ADR should be cited in each of their own discovery/foundation planning, the same way RMS's Phase 0 cited `ADR-180`.
- RMS's Prisma usage is now a recorded, understood, deliberate exception rather than an ambiguous compliance question. This resolves — and corrects — RMS's own Phase 2B "two-ORM situation" framing: there is now a real platform default, and RMS's divergence from it is named and accepted, not silently unresolved.
- No new migration-tool dependency is introduced platform-wide; every application's existing, working SQL-migration practice satisfies this ADR as long as it is versioned and applied in order — a deliberately low floor.
- A future decision to actually migrate RMS off Prisma, if ever made, is real, separate, scoped work — this ADR does not create that work, it only makes doing so optional, not owed.

## Related Documents

- Architecture: `DAT-010`
- Standards: `ENG-050`, `ENG-060`
- Reference Implementations: `reference/application` (Approved — the pattern this ADR formalises as the default)
- ADRs: `ADR-090` (resolves what it deferred), `ADR-070` (the Python-worker exception that makes a single-tool-everywhere approach structurally impossible), `ADR-060` (the data-access-layer boundary this default operates within)

## Revision History

| Version | Date       | Change        | Author |
| ------- | ---------- | ------------- | ------ |
| 0.1     | 2026-08-08 | Initial draft | Socx   |
| 1.0     | 2026-08-08 | Approved      | Socx   |

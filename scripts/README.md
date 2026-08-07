# scripts/

Executable repo and operational tooling for **this** repository — distinct from `reference/`'s copyable configuration templates and `docs/runbooks/`'s human procedure (see `reference/README.md`'s own boundary table). A reference implementation may cite a script here; it never embeds one.

Each script documents its own usage and rationale in its header comment — there's no separate manifest convention the way `reference/` and `docs/runbooks/` have, since a script's purpose is meant to be evident from running it with no arguments or reading its first ten lines.

| Script | Purpose |
|---|---|
| `check-reference-compliance.sh` | Validates `reference/`'s "no empty scaffolds" rule (`Approved` requires non-null `verified`), checks `reference/README.md`'s ToC against each manifest's real status, and flags stale `(currently empty)`/`(none yet)` citations for categories that are now `Approved` |
| `gh-issue-status.sh` | Moves a GitHub issue's Project #1 Status field without hand-crafting the GraphQL mutation each time |

## Scope discipline

Scripts here are deliberately low-blast-radius: read-only checks, or a single, narrow, reversible write (a Project field, not repository content or infrastructure). Automating a `docs/runbooks/` procedure that carries real judgment or real risk (access hardening, credential-exposure response, infrastructure provisioning) is a deliberate non-goal — see `#80`'s own Risks section for why.

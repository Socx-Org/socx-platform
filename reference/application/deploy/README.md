# deploy/

`ENG-050.4` requires project-specific deployment configuration to live in a dedicated top-level directory, separate from application source. In a consuming project, this holds that project's own filled-in copies (systemd units with real `{{APP_NAME}}`/`{{APP_DIR}}` values substituted, nginx site config, CI workflow) — never a re-implementation of the canonical pattern itself.

The canonical templates this directory's contents are copied and adapted from live elsewhere, each in its own reference implementation, and are not duplicated here:

- `reference/systemd` — service and timer units
- `reference/nginx` — edge/site configuration
- `reference/github` — CI/CD workflow, branch protection
- `reference/deployment` — deploy/rollback scripts, backup script
- `reference/security` — `.env.example`, credential provisioning

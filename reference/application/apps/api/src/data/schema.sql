-- reference/application -- illustrative schema for the widgets resource.
-- ADR-090 defers the ORM/migration-tool decision; this is a plain SQL file,
-- applied however the consuming project already manages migrations (or via
-- `psql -f` directly for this reference implementation's own verification).

CREATE TABLE IF NOT EXISTS widgets (
  id         SERIAL PRIMARY KEY,
  name       TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

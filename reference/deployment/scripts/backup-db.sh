#!/usr/bin/env bash
# reference/deployment — database backup script invoked by reference/systemd's
# db-backup@.service (OPS-060.1, OPS-060.2). Instance name (%i) is the
# database to back up.
#
# Usage:
#   backup-db.sh <db-name>
#
# Env overrides:
#   BACKUP_DIR              default: /var/backups/postgres
#   BACKUP_RETENTION_DAYS   default: 14
#   OFFHOST_TARGET           optional rsync destination, e.g.
#                             "{{BACKUP_USER}}@{{OFFHOST_HOST}}:/srv/backups/{{APP_NAME}}/"
#                             -- if unset, the backup stays local-only, and
#                             this script says so explicitly. Local-only does
#                             NOT satisfy OPS-060.2 on its own.
#
# Runs as {{BACKUP_USER}} (per db-backup@.service), which must already have
# non-interactive access to <db-name> configured (e.g. a .pgpass entry or
# peer auth) -- provisioning that access follows reference/security's
# credential pattern the same way any other secret does; it is not this
# script's concern.

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <db-name>" >&2
  exit 1
fi

DB_NAME="$1"
BACKUP_DIR="${BACKUP_DIR:-/var/backups/postgres}"
BACKUP_RETENTION_DAYS="${BACKUP_RETENTION_DAYS:-14}"
OFFHOST_TARGET="${OFFHOST_TARGET:-}"

if [ ! -d "$BACKUP_DIR" ]; then
  echo "ERROR: ${BACKUP_DIR} does not exist -- create it first, owned by the backup user, before enabling db-backup timers." >&2
  exit 1
fi

TIMESTAMP="$(date -u +%Y%m%dT%H%M%SZ)"
DUMP_FILE="${BACKUP_DIR}/${DB_NAME}-${TIMESTAMP}.sql.gz"

echo "Backing up ${DB_NAME} to ${DUMP_FILE}..."
pg_dump "$DB_NAME" | gzip > "$DUMP_FILE"

if [ ! -s "$DUMP_FILE" ]; then
  echo "ERROR: ${DUMP_FILE} is empty -- pg_dump likely failed. Removing." >&2
  rm -f "$DUMP_FILE"
  exit 1
fi

if [ -n "$OFFHOST_TARGET" ]; then
  echo "Copying to off-host target: ${OFFHOST_TARGET}"
  rsync -a "$DUMP_FILE" "$OFFHOST_TARGET"
else
  echo "WARNING: OFFHOST_TARGET is not set -- ${DUMP_FILE} exists on this host only, which does not satisfy OPS-060.2 on its own. Set OFFHOST_TARGET before relying on this for real recovery." >&2
fi

echo "Pruning local backups for ${DB_NAME} older than ${BACKUP_RETENTION_DAYS} days..."
find "$BACKUP_DIR" -maxdepth 1 -name "${DB_NAME}-*.sql.gz" -mtime "+${BACKUP_RETENTION_DAYS}" -print -delete

echo "Backup complete: ${DUMP_FILE}"

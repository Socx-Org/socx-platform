#!/usr/bin/env bash
# reference/deployment — roll back to an already-deployed release (OPS-030.3).
# For a problem found AFTER a deploy already succeeded and passed its own
# health gate. deploy-release.sh already handles automatic rollback for a
# deploy that fails immediately -- this script is for the other case.
#
# Usage:
#   rollback.sh <app-name> <target-version>
#
# The target version is always explicit, never auto-detected as "the
# previous one" -- version strings (especially the 0.0.0-<sha> form deploy-
# release.sh produces for untagged commits) don't sort reliably enough to
# guess safely. Find the right value from the host's release directory
# listing or CI run history, and name it.
#
# Env overrides: same as deploy-release.sh (APP_DIR, SERVICES, HEALTH_URL,
# HEALTH_RETRIES, HEALTH_RETRY_DELAY_SEC).
#
# Example:
#   sudo ./rollback.sh ghs 1.3.2

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <app-name> <target-version>" >&2
  echo "List available versions: ls \${APP_DIR:-/opt/<app-name>}/releases/" >&2
  exit 1
fi

APP_NAME="$1"
TARGET_VERSION="$2"

APP_DIR="${APP_DIR:-/opt/${APP_NAME}}"
SERVICES="${SERVICES:-${APP_NAME}-api.service}"
HEALTH_URL="${HEALTH_URL:-}"
HEALTH_RETRIES="${HEALTH_RETRIES:-5}"
HEALTH_RETRY_DELAY_SEC="${HEALTH_RETRY_DELAY_SEC:-2}"

TARGET_DIR="${APP_DIR}/releases/${TARGET_VERSION}"
CURRENT_LINK="${APP_DIR}/current"

if [ ! -d "$TARGET_DIR" ]; then
  echo "ERROR: ${TARGET_DIR} does not exist -- ${TARGET_VERSION} was never deployed to this host, or has been pruned." >&2
  echo "Available versions:" >&2
  ls -1 "${APP_DIR}/releases/" >&2 2>/dev/null || true
  exit 1
fi

CURRENT_TARGET=""
if [ -L "$CURRENT_LINK" ]; then
  CURRENT_TARGET="$(readlink -f "$CURRENT_LINK")"
fi
if [ "$CURRENT_TARGET" = "$TARGET_DIR" ]; then
  echo "ERROR: ${TARGET_VERSION} is already the live release -- nothing to roll back." >&2
  exit 1
fi

restart_services() {
  for svc in $SERVICES; do
    sudo systemctl restart "$svc"
  done
}

services_active() {
  for svc in $SERVICES; do
    systemctl is-active --quiet "$svc" || return 1
  done
  return 0
}

health_gate_pass() {
  local attempt
  for attempt in $(seq 1 "$HEALTH_RETRIES"); do
    if services_active; then
      if [ -z "$HEALTH_URL" ]; then
        return 0
      fi
      # See deploy-release.sh's identical line for why this is `|| true`,
      # not `|| echo 000` -- the latter double-writes onto curl's own
      # already-correct "000" output and silently defeats the health gate.
      status="$(curl -s -o /dev/null -w '%{http_code}' --max-time 2 "$HEALTH_URL")" || true
      if [ "$status" != "000" ] && [ "$status" -lt 500 ]; then
        return 0
      fi
    fi
    sleep "$HEALTH_RETRY_DELAY_SEC"
  done
  return 1
}

echo "Rolling back ${APP_NAME} to ${TARGET_VERSION} (${TARGET_DIR})..."
ln -sfn "$TARGET_DIR" "${CURRENT_LINK}.tmp"
mv -Tf "${CURRENT_LINK}.tmp" "$CURRENT_LINK"
restart_services

if health_gate_pass; then
  echo "Rollback succeeded: ${APP_NAME} ${TARGET_VERSION} is live."
  exit 0
fi

echo "ERROR: rollback to ${TARGET_VERSION} restarted but failed its own health gate. This target release is not healthy either -- manual intervention required. Does not cascade to an even older version automatically." >&2
exit 1

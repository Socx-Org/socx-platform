#!/usr/bin/env bash
# reference/deployment — deploy a versioned release and health-gate the
# restart (ADR-040, OPS-030). Extracts a release tarball into a versioned
# directory, flips the `current` symlink reference/systemd's units run
# against, restarts the affected services, and automatically rolls back to
# the previous release if the new one fails its health gate.
#
# Usage:
#   deploy-release.sh <app-name> <version> <release-tarball>
#
# Env overrides:
#   APP_DIR                  default: /opt/<app-name>
#   SERVICES                 default: "<app-name>-api.service"
#                             space-separated systemd units to restart after
#                             the symlink flip, e.g.
#                             "ghs-api.service ghs-worker.service"
#   HEALTH_URL                optional; if set, polled after restart as part
#                              of the health gate. Any HTTP status below 500
#                              (including 404) counts as alive -- this proves
#                              the process is up and serving, not that a
#                              specific route exists. No SOCX app has a
#                              confirmed dedicated health endpoint yet
#                              (OPS-040.1); this is a working default, not a
#                              requirement that one already exist. If unset,
#                              the health gate is systemctl-is-active only.
#   HEALTH_RETRIES             default: 5
#   HEALTH_RETRY_DELAY_SEC      default: 2
#
# Example:
#   sudo ./deploy-release.sh ghs 1.4.0 /tmp/release.tar.gz
#   SERVICES="ghs-api.service ghs-worker.service" HEALTH_URL="http://127.0.0.1:3000/" \
#     sudo ./deploy-release.sh ghs 1.4.0 /tmp/release.tar.gz
#
# A failed health gate rolls back automatically to the previously-live
# release and restarts it; the failed release directory is left in place
# (not deleted) for inspection. For rolling back an already-succeeded
# deploy later, use rollback.sh instead -- it takes an explicit target
# version rather than assuming "the previous one".

set -euo pipefail

if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <app-name> <version> <release-tarball>" >&2
  exit 1
fi

APP_NAME="$1"
VERSION="$2"
TARBALL="$3"

APP_DIR="${APP_DIR:-/opt/${APP_NAME}}"
SERVICES="${SERVICES:-${APP_NAME}-api.service}"
HEALTH_URL="${HEALTH_URL:-}"
HEALTH_RETRIES="${HEALTH_RETRIES:-5}"
HEALTH_RETRY_DELAY_SEC="${HEALTH_RETRY_DELAY_SEC:-2}"

RELEASE_DIR="${APP_DIR}/releases/${VERSION}"
CURRENT_LINK="${APP_DIR}/current"

if [ ! -f "$TARBALL" ]; then
  echo "ERROR: release tarball not found: ${TARBALL}" >&2
  exit 1
fi

if [ -e "$RELEASE_DIR" ]; then
  echo "ERROR: ${RELEASE_DIR} already exists -- version ${VERSION} was already deployed here. Refusing to overwrite; use a new version string." >&2
  exit 1
fi

# Record the previous release (symlink target) BEFORE touching anything, so
# a failed health gate has something concrete to roll back to. Absent on a
# host's very first deploy -- that is a real, valid state, not an error.
PREVIOUS_RELEASE=""
if [ -L "$CURRENT_LINK" ]; then
  PREVIOUS_RELEASE="$(readlink -f "$CURRENT_LINK")"
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
      status="$(curl -s -o /dev/null -w '%{http_code}' --max-time 2 "$HEALTH_URL" || echo 000)"
      if [ "$status" != "000" ] && [ "$status" -lt 500 ]; then
        return 0
      fi
    fi
    sleep "$HEALTH_RETRY_DELAY_SEC"
  done
  return 1
}

flip_symlink() {
  local target="$1"
  ln -sfn "$target" "${CURRENT_LINK}.tmp"
  mv -Tf "${CURRENT_LINK}.tmp" "$CURRENT_LINK"
}

echo "Deploying ${APP_NAME} ${VERSION} to ${RELEASE_DIR}..."
mkdir -p "$RELEASE_DIR"
tar -xzf "$TARBALL" -C "$RELEASE_DIR"

flip_symlink "$RELEASE_DIR"
restart_services

echo "Health-gating (up to ${HEALTH_RETRIES} attempts, ${HEALTH_RETRY_DELAY_SEC}s apart)..."
if health_gate_pass; then
  echo "Deploy succeeded: ${APP_NAME} ${VERSION} is live."
  exit 0
fi

echo "Health gate FAILED for ${APP_NAME} ${VERSION}." >&2

if [ -z "$PREVIOUS_RELEASE" ]; then
  echo "No previous release to roll back to (this was the first deploy to this host) -- leaving ${RELEASE_DIR} in place for inspection. Manual intervention required." >&2
  exit 1
fi

echo "Rolling back to ${PREVIOUS_RELEASE}..." >&2
flip_symlink "$PREVIOUS_RELEASE"
restart_services

if health_gate_pass; then
  echo "Rollback succeeded: previous release is live again. Failed release retained at ${RELEASE_DIR} for inspection." >&2
else
  echo "ERROR: rollback restart also failed its health gate -- manual intervention required immediately." >&2
fi
exit 1

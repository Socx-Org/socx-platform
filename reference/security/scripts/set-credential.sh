#!/usr/bin/env bash
# reference/security — safely provision or rotate a systemd credential file
# (ADR-130, SEC-010.3/.5). The same operation serves both first-time
# provisioning and later rotation; a credential file is simply overwritten.
#
# Also the mechanism ADR-110 realises: a service-to-service credential
# (once ADR-120's shared OIDC provider exists) is provisioned identically --
# just a different credential name under the same app's directory. Actual
# OIDC client registration / token exchange is NOT covered here, only the
# at-rest handling pattern every credential type uses.
#
# Usage:
#   sudo ./set-credential.sh <app-name> <credential-name>
#
# The secret VALUE is read from stdin, never a CLI argument -- an argument
# would leak into shell history and any `ps` output while the script runs.
# The value is never echoed back or logged (SEC-010.5).
#
# Examples:
#   openssl rand -base64 32 | sudo ./set-credential.sh ghs jwt_secret
#   printf '%s' "$REAL_DB_PASSWORD" | sudo ./set-credential.sh ghs db_password
#
# Service-to-service credential, once ADR-120's provider exists (naming
# convention only -- the mechanism is identical):
#   printf '%s' "$OIDC_CLIENT_SECRET" | sudo ./set-credential.sh ghs rms_client_secret

set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <app-name> <credential-name>" >&2
  echo "Secret value is read from stdin." >&2
  exit 1
fi

APP_NAME="$1"
CRED_NAME="$2"
CRED_DIR="/etc/credentials/${APP_NAME}"
CRED_PATH="${CRED_DIR}/${CRED_NAME}"

if [ "$(id -u)" -ne 0 ]; then
  echo "Must run as root (or via sudo) -- credential files are root-only." >&2
  exit 1
fi

if [ ! -d "$CRED_DIR" ]; then
  echo "ERROR: ${CRED_DIR} does not exist." >&2
  echo "Create the app's credentials directory first (reference/systemd, Bootstrap Phase B4 pattern: mode 700, root:root)." >&2
  exit 1
fi

# Write atomically: a temp file in the SAME directory (same filesystem, so
# the final rename is atomic), permissions locked down before any content
# lands, then renamed into place. Never write CRED_PATH directly -- a
# reader (or a script that crashes mid-write) could otherwise observe a
# partial file.
TMP_FILE="$(mktemp "${CRED_DIR}/.${CRED_NAME}.XXXXXX")"
trap 'rm -f "$TMP_FILE"' EXIT

chmod 600 "$TMP_FILE"
chown root:root "$TMP_FILE"
cat > "$TMP_FILE"

if [ ! -s "$TMP_FILE" ]; then
  echo "ERROR: no data received on stdin -- refusing to write an empty credential." >&2
  exit 1
fi

mv -f "$TMP_FILE" "$CRED_PATH"
trap - EXIT

echo "Credential written: ${CRED_PATH} (mode 600, root:root). Value not logged."
echo "If a running service reads this credential via LoadCredential=, restart it to pick up the new value:"
echo "  sudo systemctl restart ${APP_NAME}-api.service"

# reference/security — Python-side credential consumption (ADR-130, SEC-010.3)
#
# reference/application's config.ts demonstrates this same pattern for
# Node/TypeScript services. This is the equivalent for a Python worker
# (ADR-070's bounded, per-project exception to the general Node/TS/Express
# stack — not a second general-purpose application pattern, just this one
# runtime's version of the same idea).
#
# Populates os.environ from systemd LoadCredential= files when running
# under systemd (CREDENTIALS_DIRECTORY set), so existing
# os.environ.get('SOME_VAR') call sites elsewhere in the codebase need no
# changes. In local/dev, where CREDENTIALS_DIRECTORY is unset, this is a
# no-op and whatever dotenv-based loading the project already has takes
# over instead.
#
# Adapted from a real, tested implementation (Socx-Org/rms's
# apps/worker/engine/credentials.py) -- not a hypothetical pattern.
import os

# One entry per credential this worker needs, mapping the systemd
# credential name (the file under $CREDENTIALS_DIRECTORY) to the
# environment variable the rest of the codebase already reads.
CREDENTIAL_ENV_MAP = {
    "db_password": "DB_PASSWORD",
    # "some_api_key": "SOME_API_KEY",
}


def load_credentials_into_env():
    cred_dir = os.environ.get("CREDENTIALS_DIRECTORY")
    if not cred_dir:
        return
    for credential_name, env_var in CREDENTIAL_ENV_MAP.items():
        path = os.path.join(cred_dir, credential_name)
        try:
            with open(path, "r", encoding="utf-8") as f:
                os.environ[env_var] = f.read().strip()
        except OSError as err:
            raise RuntimeError(
                f"Failed to read credential '{credential_name}' from {cred_dir}: {err}"
            ) from err

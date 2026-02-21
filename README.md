# openhab-docker-graalpy-venv

## Description
OpenHab docker image that automatically create a python venv using graalpy ready to be used with https://www.openhab.org/addons/automation/pythonscripting/

Currently only supports OpenHAB 5.1.2

## Image details
- installs the GraalPy community runtime that matches the built-in OpenHAB GraalVM version (currently `25.0.1` for openhzab 5.1.2) - as documented at https://www.openhab.org/addons/automation/pythonscripting/ 
- keeps the runtime in `/opt/graalpy`
- wraps the base entrypoint (`docker-entrypoint.sh`) to ensure the GraalPy virtual environment under `/openhab/userdata/cache/org.openhab.automation.pythonscripting/venv` (override with `PYTHON_VENV_PATH`) is initialized on every startup, even if `/openhab/userdata` is mounted from the host; this keeps the helper libs and native modules installable via pip;
- includes tooling such as `patchelf` needed for GraalPy to support native extensions.

## Building locally
```bash
docker build -t openhab-graalpy .
```
You can override `GRAALPY_VERSION` or `GRAALPY_DIST` via `--build-arg` if you need a different GraalPy release or architecture.

## GitHub Actions
`.github/workflows/build-image.yml` builds the image using Buildx, caches layers, and pushes to `ghcr.io/<OWNER>/openhab-graalpy` on pushes to `main`. Configure the appropriate registry permissions or tokens if you want the workflow to publish the image.


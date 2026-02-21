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
You can override `GRAALPY_VERSION`, `GRAALPY_DIST`, or `OPENHAB_BASE_TAG` via `--build-arg` when you need a different GraalPy release or OpenHAB base image.

## GitHub Actions
`.github/workflows/build-image.yml` uses Docker Buildx to build the image on pushes to `main`, caches layers, and pushes `ghcr.io/<OWNER>/openhab-graalpy:latest` plus a numeric run number. A separate release job listens for Git tags (and manual `workflow_dispatch` runs) so you can mirror the OpenHAB tag one-to-one when publishing.

## Release process
- Update the Dockerfile (GraalPy version, helper tooling, docs, etc.) so it matches the OpenHAB release you want to mirror, then commit those changes on `main`.
- Create a Git tag that exactly equals the OpenHAB base image tag (for example, `git tag 5.1.2-debian`), then push it with `git push origin --tags`. The release workflow reads that tag as `OPENHAB_BASE_TAG`, builds against `openhab/openhab:<tag>`, and labels the image accordingly.
- The release job pushes both `ghcr.io/<OWNER>/openhab-graalpy:<tag>` (1:1 mirror of the upstream tag) and `ghcr.io/<OWNER>/openhab-graalpy:latest` so testers can always pull the most recent release in addition to the explicit versioned tag.
- You can also trigger the release job manually via the workflow dispatch input if you need to rebuild a specific OpenHAB tag without pushing a Git tag.

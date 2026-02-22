#!/usr/bin/env python3
"""Host-side smoke test for the GraalPy venv and python rules."""

import errno
import json
import sys
import time
import urllib.error
import urllib.request


BASE_URL = "http://localhost:8080/rest"


def wait_for_openhab(timeout: float = 120.0, interval: float = 5.0) -> None:
    end = time.monotonic() + timeout

    while time.monotonic() < end:
        try:
            req = urllib.request.Request(BASE_URL, headers={"Accept": "application/json"})
            with urllib.request.urlopen(req, timeout=5):
                print("OpenHAB REST API is available")
                return
        except urllib.error.URLError: 
            time.sleep(interval)
        except OSError as exc:
            if exc.errno == errno.ECONNRESET:
                print("OpenHAB REST API resetting the connection while starting; retrying")
                time.sleep(interval)
                continue
            raise

    raise RuntimeError("OpenHAB REST API did not become available within timeout")


def fetch_item_state(item: str) -> str:
    url = f"{BASE_URL}/items/{item}"
    req = urllib.request.Request(url, headers={"Accept": "application/json"})
    with urllib.request.urlopen(req, timeout=5) as response:
        payload = json.load(response)
    return payload["state"]


def wait_for_state(item: str, expected: str, timeout: float = 120.0, interval: float = 5.0) -> str:
    end = time.monotonic() + timeout
    last_state = None

    while time.monotonic() < end:
        try:
            state = fetch_item_state(item)
            last_state = state
        except Exception as exc:  # pragma: no cover - allow retries
            last_state = f"error: {exc}"
            time.sleep(interval)
            continue

        if state == expected:
            print(f"{item} reached expected state: {state}")
            return state

        time.sleep(interval)

    raise RuntimeError(
        f"Item {item} did not reach expected state {expected} within {timeout} seconds (last state: {last_state})"
    )


def main() -> int:
    try:
        wait_for_openhab()
        simple = wait_for_state("SimpleItem", "42")
        status = wait_for_state("RequestsStatus", "200")
        print(f"Smoke test succeeded: SimpleItem={simple}, RequestsStatus={status}")
        return 0
    except Exception as exc:  # pragma: no cover - top-level reporting
        print(f"Smoke test failed: {exc}")
        return 1


if __name__ == "__main__":
    raise SystemExit(main())

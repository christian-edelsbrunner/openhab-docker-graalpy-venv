import time

import requests

from openhab import Registry, rule
from openhab.triggers import when


@rule(tags=["venv-test"])
@when("System started")
class RequestsRule:
    def execute(self, module, input):
        status_code = 0
        deadline = time.monotonic() + 60.0

        while time.monotonic() < deadline:
            try:
                response = requests.get("http://localhost:8080/rest/items/SimpleItem", timeout=10)
                status_code = response.status_code
                break
            except Exception as exc:
                self.logger.warning("REST API not yet reachable, retrying: %s", exc)
                time.sleep(5)

        Registry.getItem("RequestsStatus").postUpdate(status_code)

import requests

from openhab import Registry, rule
from openhab.triggers import when


@rule(tags=["venv-test"])
@when("System started")
class RequestsRule:
    def execute(self, module, input):
        status_code = 0
 
        try:
            # This Test requires the requests package to be installed in the venv, which is done in the Dockerfile. If the package is missing or fails to load, this will raise an exception which we catch and log here.
            response = requests.get("http://localhost:8080/rest/items/SimpleItem", timeout=10)
            status_code = response.status_code
        except Exception as exc:
            requests_rule.logger.error("failed to probe REST API: %s", exc)

        Registry.getItem("RequestsStatus").postUpdate(status_code)
 
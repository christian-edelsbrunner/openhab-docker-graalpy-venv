from openhab import Registry, rule
from openhab.triggers import when


@rule(tags=["venv-test"])
@when("System started")
class SimpleUpdateRule:
    def execute(self, module, input):
        Registry.getItem("SimpleItem").postUpdate(42)
 
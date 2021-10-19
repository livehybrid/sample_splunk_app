import os
import sys
import time
import datetime
import json
import re
import requests
splunkhome = os.environ['SPLUNK_HOME']
sys.path.append(os.path.join(splunkhome, 'etc', 'apps', 'sample_splunk_app', 'lib'))

#from splunktaucclib.modinput_wrapper.base_modinput import BaseModInput
from splunklib import modularinput as smi

class MySampleApp(smi.Script):

    def get_scheme(self):
        # Returns scheme.
        scheme = smi.Scheme("EV Charger Usage")
        scheme.description = ("Sample modular input")
        scheme.use_external_validation = True
        scheme.streaming_mode_xml = True

        scheme.add_argument(smi.Argument("name", title="Name",
                                         description="",
                                         required_on_create=True))

        return scheme


    def validate_input(self, validation_definition):
        return True
    # Validates input.

    def stream_events(self, inputs, ew):
        response = requests.get("https://engie.geniecpms.com/PublicMap/GetAllLocations?includeNCR=false")
        r_json = response.json()
        event = smi.Event()
        event.data = json.dumps(r_json)
        ew.write_event(event)

if __name__ == "__main__":
    sys.exit(MySampleApp().run(sys.argv))

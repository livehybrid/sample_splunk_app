import os
from splunk_add_on_ucc_framework import get_ignore_list, remove_listed_files
from splunk_add_on_ucc_framework.app_manifest import AppManifest, APP_MANIFEST_FILE_NAME
class additional_packaging:
    def __init__(self, ta_name):
        ignore_list = get_ignore_list(
            ta_name, os.path.abspath(os.path.join("output", "..", ".uccignore"))
        )
        remove_listed_files(ignore_list)

#!/bin/bash

set -x

acs config add-stack $ACS_STACK
export STACK_TOKEN=$ACS_TOKEN
acs config use-stack $ACS_STACK

acs login
acs status current-stack

#acs apps install private --app-package $1 --acs-legal-ack=Y
acs apps bulk-install private --package-src-dir dist/ --acs-legal-ack=Y

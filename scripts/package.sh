#!/usr/bin/env bash

set -e


BUILD_DIR="${1-./build}"
DIST_DIR="${2-./dist}"
REPORTS="${3-./tmp/reports}"
PACKAGE_DIR="${4-./package}"


PACKAGE_DIR=$(realpath "${PACKAGE_DIR}")

APP_ID=$(crudini --get "${PACKAGE_DIR}/default/app.conf" package id | tr -d '[:cntrl:]')

BUILD_DIR=$(realpath "${BUILD_DIR}/${APP_ID}")

echo "packaging ${BUILD_DIR} to ${DIST_DIR}"

mkdir -p "${DIST_DIR}"

slim package -o "${DIST_DIR}" "${BUILD_DIR}"

PACKAGE="$(find """${DIST_DIR}""" -type f -name '*.tar.gz')"


splunk-appinspect inspect "${PACKAGE}" --data-format junitxml --output-file "${REPORTS}/${APP_ID}-appapproval.xml" --excluded-tags manual --excluded-tags prerelease  --included-tags appapproval --included-tags future
splunk-appinspect inspect "${PACKAGE}" --data-format junitxml --output-file "${REPORTS}/${APP_ID}-self-service.xml" --excluded-tags manual --excluded-tags prerelease  --included-tags self-service
splunk-appinspect inspect "${PACKAGE}" --data-format junitxml --output-file "${REPORTS}/${APP_ID}-self-service.xml" --included-tags private_app

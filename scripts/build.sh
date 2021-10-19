#!/usr/bin/env bash

set -e

PACKAGE_DIR="${1-./package}"
DEST_DIR="${2-./output}"
MAIN_GIT_BRANCH="${2-master}"

echo "building ${PACKAGE_DIR} to ${BUILD_DIR}"

PACKAGE_DIR=$(realpath "${PACKAGE_DIR}")

APP_ID=$(crudini --get "${PACKAGE_DIR}/default/app.conf" package id | tr -d '[:cntrl:]')
APP_LABEL=$(crudini --get "${PACKAGE_DIR}/default/app.conf" ui label | tr -d '[:cntrl:]')
APP_DESCRIPTION=$(crudini --get "${PACKAGE_DIR}/default/app.conf" launcher description | tr -d '[:cntrl:]')

mkdir -p "${DEST_DIR}"

BUILD_DIR=$(realpath "${DEST_DIR}/${APP_ID}")

mkdir -p "${BUILD_DIR}"

echo "packaging ${PACKAGE_DIR} to ${BUILD_DIR}"

cp -r "${PACKAGE_DIR}"/* "${BUILD_DIR}"


BRANCH=$(git branch | grep \* | cut -d ' ' -f2)

if [ "$BRANCH" == "$MAIN_GIT_BRANCH" ]; then
  APP_VERSION="$(python3 scripts/get-next-version.py)"
else
  APP_VERSION="$(versioningit)"
fi

export APP_VERSION="${APP_VERSION}"
export APP_LABEL="${APP_LABEL}"
export APP_DESCRIPTION="${APP_DESCRIPTION}"
echo "Packaging ${APP_ID}"
echo "Package Version: ${APP_VERSION}"
echo "Label: ${APP_LABEL}"

slim generate-manifest "${BUILD_DIR}" |  grep -Ev '^#' > "${BUILD_DIR}/app.manifest"

json="$(jq '.info.title=env.APP_LABEL' """${BUILD_DIR}/app.manifest""")" && echo "${json}" > "${BUILD_DIR}/app.manifest"
json="$(jq '.info.description=env.APP_DESCRIPTION' """${BUILD_DIR}/app.manifest""")" && echo "${json}" > "${BUILD_DIR}/app.manifest"
json="$(jq '.info.id.version=env.APP_VERSION' """${BUILD_DIR}/app.manifest""")" && echo "${json}" > "${BUILD_DIR}/app.manifest"


crudini --set "${BUILD_DIR}/default/app.conf" launcher version "${APP_VERSION}"
crudini --set "${BUILD_DIR}/default/app.conf" ui label "${APP_LABEL}"
crudini --set "${BUILD_DIR}/default/app.conf" package version "${APP_VERSION}"

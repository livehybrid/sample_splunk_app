#!/bin/bash
set -x
export STACK=$1
export SPLUNKBASE_TOKEN=$(./scripts/splunkbase_auth.sh)
echo $SPLUNKBASE_TOKEN
app_file=dist/$(/bin/ls -1 dist/)
echo "Uploading file $app_file"
export APPINSPECT_UPLOAD_ID=$(./scripts/appinspect_upload.sh $app_file)
echo "$APPINSPECT_UPLOAD_ID"
echo "Got upload_id=$APPINSPECT_UPLOAD_ID"
while [ true ]; do
    status=$(./scripts/appinspect_status.sh)
    if [ "$status" == "PROCESSING" ]; then
      echo -n .
      sleep 5
    else
      echo $status
      break
    fi
done
if [ "$status" == "SUCCESS" ]; then
  echo "Uploading to Splunk Cloud"
  ./script/splunkcloud_upload.sh $app_file
fi
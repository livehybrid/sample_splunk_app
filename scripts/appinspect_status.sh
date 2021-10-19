status_resp=$(curl -s --location --request GET "https://appinspect.splunk.com/v1/app/validate/status/$SPLUNKBASE_UPLOAD_ID" --header "Authorization: bearer $SPLUNKBASE_TOKEN")
status=$(echo $status_resp | jq -r '.status')
#echo $(echo $status_resp | jq -r '.info')
echo $status
splunkbase_resp=$(curl --location --request GET 'https://api.splunk.com/2.0/rest/login/splunk' --header "Authorization: Basic ${SPLUNKBASE_AUTH}" -s)
status_code=$(echo $splunkbase_resp | jq -r '.status_code')
if [ "$status_code" == "200" ]; then
  token=$(echo $splunkbase_resp | jq -r '.data.token')
  echo $token
  exit 0
else
  echo "Failed_to_get_splunkbase_token"
  exit 1
fi



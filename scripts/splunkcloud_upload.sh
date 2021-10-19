set -x

upload_resp=$(curl --location --request POST "https://admin.splunk.com/$STACK/adminconfig/v2beta1/apps" \
--header "Authorization: Bearer $SPLUNKCLOUD_TOKEN" \
--form "token=$SPLUNKBASE_TOKEN" \
--form "package=@$1")
echo $upload_resp
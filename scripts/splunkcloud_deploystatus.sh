taskId=$(curl https://$STACK.splunkcloud.com:8089/services/dmc/deploy -s \
--header "Authorization: Bearer $SPLUNKCLOUD_TOKEN" | jq -r '.entry[0].content.taskId')
curl https://$STACK.splunkcloud.com:8089/services/dmc/tasks/$taskId -s \
--header "Authorization: Bearer $SPLUNKCLOUD_TOKEN" | jq -r '.entry[0].content.state'


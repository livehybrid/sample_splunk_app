#!/usr/bin/env bash

set -e

echo ""
echo "getting host container volume for splunk"
hostcontainer=$(grep -o -P -m1 'docker.*\K[0-9a-f]{64,}' /proc/self/cgroup)
volume=$(docker inspect "${hostcontainer}" -f '{{json .Mounts }}' | jq '.[] | select(.Destination=="/builds") | .Source' -r)
subdir=$(echo $PWD | sed -e 's#^/builds/##')
volume="${volume}/${subdir}"
sed -i "s#- './#- '"${volume}"/#" ./docker-compose.yml


echo ""
echo "starting splunk"
docker-compose -f docker-compose.yml -f docker-compose.cicd.yml up -d
docker cp output/app $(docker-compose ps -q splunk):/opt/splunk/etc/apps/$1
scripts/wait-for-log-line.sh splunk 'Ansible playbook complete'

echo ""
echo "connecting to splunk network"
hostcontainer=$(grep -o -P -m1 'docker.*\K[0-9a-f]{64,}' /proc/self/cgroup)
splunkcontainer=$(docker-compose ps -q splunk)
splunknetwork=$(docker inspect ${splunkcontainer} -f '{{json .NetworkSettings.Networks }}' | jq -r 'keys[0]')
docker network connect ${splunknetwork} ${hostcontainer}
#!/bin/bash

target_extension=""
target_mapping=""

while read -r property value; do
    if [ "$property" == "agi_extension:" ] ; then
	target_extension=$(echo "$value" | sed 's/^100//')
    fi

    if [ "$property" == "agi_callerid:" ] ; then
	target_mapping="$value"
    fi

    if [ -z "$property" ]; then
	break
    fi
done

echo "Registering ${target_extension} to ${target_mapping}" >&2

# Get HMS Token
response=$(curl -s -H 'Content-Type: application/json' \
		-X POST \
		-d "{\"grant_type\": \"client_credentials\", \"client_id\": ${HMS_CLIENT_ID}, \"client_secret\": \"${HMS_CLIENT_SECRET}\"}" \
		"${HMS_ENDPOINT}/oauth/token")
token=$(echo "$response" | jq -r '.access_token')

# Attempt registration
status_code=$(curl -s -H 'Content-Type: application/json' \
		-H "Authorization: Bearer $token" \
		-X POST \
		-d "{\"extension\": \"${target_extension}\", \"target\": \"${target_mapping}\"}" \
		-o /dev/stderr --write-out "%{http_code}" \
		"${HMS_ENDPOINT}/api/cc/phones/extensions/map")

echo "Registration status code: ${status_code}" >&2

if [ "$status_code" == "204" ] ; then
    echo "STREAM FILE /etc/asterisk/sounds/registration-success \"\" 0" 
else
    echo "STREAM FILE /etc/asterisk/sounds/registration-failed \"\" 0"
fi

echo "Rebuilding extensions-hms.conf" >&2
(
curl -s -H 'Content-Type: application/json' \
		-H "Authorization: Bearer $token" \
		-X GET \
		"${HMS_ENDPOINT}/api/cc/phones/dialplan" | \
    jq -r '.[] | "\(.extension) \(.target)"' | \
    while read extension target ; do
	echo "exten => ${extension},1,Dial(PJSIP/${target})"
    done
) > /etc/asterisk/extensions-hms.conf

read -r agi_reply
echo "Got to STREAM FILE: $agi_reply" >&2

asterisk -rx "dialplan reload"

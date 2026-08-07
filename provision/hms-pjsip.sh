#!/bin/bash

function renew_hms_token () {
    # Get HMS Token
    response=$(curl -s -H 'Content-Type: application/json' \
		    -X POST \
		    -d "{\"grant_type\": \"client_credentials\", \"client_id\": ${HMS_CLIENT_ID}, \"client_secret\": \"${HMS_CLIENT_SECRET}\"}" \
		    "${HMS_ENDPOINT}/oauth/token")

    echo "$response" | jq -r '.access_token' > /tmp/hms-token
}

if [ ! -f /tmp/hms-token ] ; then
    echo "Renewing HMS token"
    renew_hms_token
fi

token=$(cat /tmp/hms-token)

if [ ! -f /etc/asterisk/pjsip-hms.conf ] ; then
    touch /etc/asterisk/pjsip-hms.conf
fi
old_checksum=$(md5sum /etc/asterisk/pjsip-hms.conf)

status=$(curl -s -H 'Content-Type: application/json' \
		-H "Authorization: Bearer $token" \
		-X GET \
		-o /tmp/hms-sip-extensions --write-out "%{http_code}" \
		"${HMS_ENDPOINT}/api/cc/phones/extensions/sip")

echo "/phones/extensions/sip returned $status"


if [ "$status" == "200" ] ; then
    cat /tmp/hms-sip-extensions | \
	jq -r '.[] | "\(.extension)\t\(.password)"' | \
	while read extension password ; do
	    cat <<EOF
[$extension]
type=endpoint
context=hack
disallow=all
allow=ulaw
allow=alaw
aors=$extension
[$extension](aor-single)
[$extension]
type=auth
auth_type=userpass
username=$extension
password=$password

EOF
	done > /etc/asterisk/pjsip-hms.conf

    checksum=$(md5sum /etc/asterisk/pjsip-hms.conf)
    echo "pjsip-hms.conf md5 $checksum"

    if [ "$old_checksum" != "$checksum" ] ; then
	echo "Difference detected - time to reload pjsip"
	asterisk -rx "pjsip reload"
    fi
fi

if [ "$status" == "302" ] ; then
    renew_hms_token
    # We'll get the new copy next time :)
fi

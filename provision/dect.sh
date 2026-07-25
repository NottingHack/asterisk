#!/bin/bash

# This script generates config files for Panasonic DECT base stations,
# as well as corresponding pjsip configs for Asterisk.

> dect.conf
> pjsip-dect.conf

SIP="10.0.0.19"
CONF=

(
echo -e "# Panasonic SIP Phone Standard Format File #\r"
echo -e "# DO NOT CHANGE THIS LINE!\r"
echo -e "HTTPD_PORTOPEN_AUTO=\"Y\"\r"
echo -e "CFG_SYSTEM_FILE_PATH=\"http://10.0.0.193/dect.cfg\"\r"
echo -e "SIP_PRXY_ADDR=\"$SIP\"\r"
echo -e "SIP_RGSTR_ADDR=\"$SIP\"\r"
) >> dect.conf

seq 1 255 | while read ps; do
    num=$(printf '333%04d' "$ps")
    pass=$(tr -dc a-z0-9 </dev/urandom | head -c 13)

    (
	echo -e "LINE_ENABLE_PS${ps}_1=\"Enabled\"\r"
	echo -e "DISPLAY_NAME_PS${ps}_1=\"Asterisk $ps\"\r"
	echo -e "SIP_URI_PS${ps}_1=\"sip:$num@$SIP\"\r"
	echo -e "SIP_PASS_PS${ps}_1=\"$pass\"\r"
    ) >> dect.conf

    (
	echo ""
	echo ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;"
	echo "; DECT $num"
	echo "[$num]"
	echo "type=endpoint"
	echo "context=dect"
	echo "allow=all"
	echo "aors=$num"
	echo "[$num](aor-single)"
	echo "[$num]"
	echo "type=auth"
	echo "authtype=userpass"
	echo "username=$num"
	echo "password=$pass"
    ) >> pjsip-dect.conf
done

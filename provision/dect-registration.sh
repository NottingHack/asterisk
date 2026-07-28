#!/bin/bash

# This script puts the Panasonic SIP CS KX-UDS124CE into registration
# mode, which we basically want it to be in all the time, but it times
# out after a few minutes.

# Receive a list of available slots
> /tmp/dect-available-ids
curl -s --digest 'http://admin:adminpass@10.0.0.71/CgiStart.cgi?Page=sys_ps_reg_strt&tab=1' > /tmp/dect-available-id

ids=$(xq -q 'body option' < /tmp/dect-available-id)
rand=$(xq -q 'body input[name=RAND]' -a value < /tmp/dect-available-id)

args=$(
    echo -n "RAND=$rand"
    echo "$ids" | while read id ; do
	echo -n "&ps$id=$id"
    done
    )

curl -s -X POST --digest --cookie "login=1" -d "$args" 'http://admin:adminpass@10.0.0.71/CgiStart.cgi?Page=sys_ps_reg_strt&tab=1' > /dev/null

rm /tmp/dect-available-ids

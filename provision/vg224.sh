#!/bin/bash

> vg224.conf
> pjsip-vg224.conf

seq 0 23 | while read i ; do
    num=$(printf '332%03d' $(( i + 1)))
    pass=$(tr -dc a-z0-9 </dev/urandom | head -c 13)

    cat >> vg224.conf <<EOF
voice-port 2/$i
 ring cadence pattern11
 compand-type a-law
 cptone GB
 station-id number $num
 caller-id enable
!
dial-peer voice 1$num pots
 preference 1
 destination-pattern $num
 port 2/$i
 authentication username $num password $pass
!
dial-peer voice 2$num voip
 voice-class codec 1
 corlist incoming inbound
 corlist outgoing outbound
 huntstop
 preference 1
 destination-pattern $num
 session protocol sipv2
 session target sip-server
 dtmf-relay rtp-nte
!
EOF

cat >> pjsip-vg224.conf <<EOF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; POTS $num
[$num]
type=endpoint
context=hack
allow=all
aors=$num
[$num](aor-single)
[$num]
type=auth
auth_type=userpass
username=$num
password=$pass
EOF

done

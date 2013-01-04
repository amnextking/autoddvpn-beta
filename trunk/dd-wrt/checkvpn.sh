#!/bin/sh

VPNLOG='/tmp/autoddvpn.log'
VPNLOCK='/tmp/autoddvpn.lock'
PID=$$
INFO="[INFO#${PID}]"
DEBUG="[DEBUG#${PID}]"
ERROR="[ERROR#${PID}]"
WANGW=$(nvram get wan_gateway)

while [ 1 ]
do
    for i in 1 2 3 4 5
    do
        if [ ! -f $VPNLOCK ]; then
            NOWGW=$(route -n | grep ^0.0.0.0 | awk '{print $2}')
            if [ "$NOWGW" == "$WANGW" ]; then
                echo "$ERROR $(date "+%d/%b/%Y:%H:%M:%S") Check VPN: got the old gw, seems the VPN is disconnected, will check again in 10sec. $i/5" >> $VPNLOG
                if [ $i -eq 5 ]; then
                    if [ ! -f $VPNLOCK ]; then
                        echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") Check VPN: still got the old gw, trying to reconnect to the VPN." >> $VPNLOG
                        /tmp/pptpd_client/vpn stop
                        /tmp/pptpd_client/vpn start
                    fi
                    continue
                fi
                sleep 10
            else
                echo "$DEBUG Check VPN: vpn connection is well now, will check again in 1min."
                break
            fi
        else
            break
        fi
    done
    sleep 60
done

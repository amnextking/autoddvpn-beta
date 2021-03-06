#!/bin/sh
# This is the VPN connection checking script for dd-wrt router using PPTP VPN manual connection mode

VPNLOG='/tmp/autoddvpn.log'
VPNLOCK='/tmp/autoddvpn.lock'
PID=$$
INFO="[INFO#${PID}]"
DEBUG="[DEBUG#${PID}]"
ERROR="[ERROR#${PID}]"
CKPIDFILE="/var/run/checkvpn.pid"

# create PID file
echo -n ${PID} > "${CKPIDFILE}"

# get WAN gateway
WANGW=$(nvram get wan_gateway)

# starting checking
while [ 1 ]
do
    for i in 1 2 3 4 5
    do
        NOWGW=$(route -n | grep ^0.0.0.0 | awk '{print $2}')
        if [ "$NOWGW" == "$WANGW" ]; then
            if [ ! -f $VPNLOCK ]; then
                echo "$ERROR $(date "+%d/%b/%Y:%H:%M:%S") Check VPN: got the old gw, seems the VPN is disconnected, will check again in 10sec. $i/5" >> $VPNLOG
                if [ $i -eq 5 ]; then
                    if [ ! -f $VPNLOCK ]; then
                        echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") Check VPN: still got the old gw, trying to reconnect to the VPN." >> $VPNLOG
                        nohup /jffs/pptp/manual/reconnect.sh > /dev/null &
                    fi
                    continue
                fi
                sleep 10
            else
                break
            fi
        else
            echo "$DEBUG Check VPN: vpn connection is well now, will check again in 1min."
            break
        fi
    done
    sleep 60
done

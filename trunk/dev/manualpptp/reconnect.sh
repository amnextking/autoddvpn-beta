#!/bin/sh
# Shujen & Park
# We're together forever!

VPNLOG='/tmp/autoddvpn.log'
PID=$$
INFO="[INFO#${PID}]"

sleep 2
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") trying to kill PPTP process" >> $VPNLOG
PPTPPID=`pidof -s pptp`
kill $PPTPPID
sleep 2
kill -9 $PPTPPID
sleep 2
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") trying to reconnect to PPTP server" >> $VPNLOG
pptp `cat /jffs/pptp/manual/ipaddress.conf` file /jffs/pptp/manual/options.vpn &
exit 0

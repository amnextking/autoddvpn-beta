#!/bin/sh

sleep 2
PPTPPID=`pidof -s pptp`
kill $PPTPPID
sleep 2
kill -9 $PPTPPID
sleep 2
pptp <vpn_server_ip> file /jffs/pptp/manual/options.vpn &
exit 0

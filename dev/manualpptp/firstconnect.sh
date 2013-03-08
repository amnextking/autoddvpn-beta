#!/bin/sh
# Shujen & Park
# We're together forever!

VPNLOG='/tmp/autoddvpn.log'
PID=$$
INFO="[INFO#${PID}]"
ERROR="[ERROR#${PID}]"

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") log starts" >> $VPNLOG
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") pptp+jffs manual mode" >> $VPNLOG

# Checking files
if [ ! -f /jffs/pptp/manual/vpnsrvsub.conf ]; then
    echo "$ERROR $(date "+%d/%b/%Y:%H:%M:%S") no vpnsrvsub.conf" >> $VPNLOG
    exit 1
fi
if [ ! -f /jffs/pptp/manual/vpnsrvsubmsk.conf ]; then
    echo "$ERROR $(date "+%d/%b/%Y:%H:%M:%S") no vpnsrvsubmsk.conf" >> $VPNLOG
    exit 1
fi

# Set nvram
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnsrvsub.conf and vpnsrvsubmsk.conf found, setting nvram..." >> $VPNLOG
nvram set pptpd_client_srvsub="`cat /jffs/pptp/manual/vpnsrvsub.conf`"
nvram set pptpd_client_srvsubmsk="`cat /jffs/pptp/manual/vpnsrvsubmsk.conf`"
nvram commit

# Resolve VPN IP address
if [ -f /jffs/pptp/manual/domainname.conf ]; then
    rm -f /jffs/pptp/manual/ipaddress.conf
    echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") trying to resolve VPN IP address from domain name" >> $VPNLOG
    if [ $(ping -w 1 -c 1 `cat /jffs/pptp/manual/domainname.conf` | grep -Eo "\(([0-9.]+)" | cut -d\( -f 2) == $(ping -w 1 -c 1 domainnotexists | grep -Eo "\(([0-9.]+)" | cut -d\( -f 2) ]; then
        echo "$ERROR $(date "+%d/%b/%Y:%H:%M:%S") Can't resolve the ip address from domainname.conf" >> $VPNLOG
        exit 1
    else
        echo -n $(ping -w 1 -c 1 `cat /jffs/pptp/manual/domainname.conf` | grep -Eo "\(([0-9.]+)" | cut -d\( -f 2) >> /jffs/pptp/manual/ipaddress.conf
        echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") resolved the ip address from domainname.conf and saved it to ipaddress.conf" >> $VPNLOG
    fi
fi
if [ ! -f /jffs/pptp/manual/ipaddress.conf ]; then
    echo "$ERROR $(date "+%d/%b/%Y:%H:%M:%S") no ipaddress.conf" >> $VPNLOG
    exit 1
fi

#Connect to VPN
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") ALL DONE. Let's wait for VPN being connected." >> $VPNLOG
pptp `cat /jffs/pptp/manual/ipaddress.conf` file /jffs/pptp/manual/options.vpn &
exit 0

#!/bin/sh

set -x
export PATH="/bin:/sbin:/usr/sbin:/usr/bin"

LOG='/tmp/autoddvpn.log'
LOCK='/tmp/autoddvpn.lock'
IPTABLELOCK='/tmp/iptable.lock'
CHECKVPNLOCK='/tmp/checkvpn.lock'
PID=$$
CNIPLIST='/jffs/cnips.lst'
EXROUTEDIR='/jffs/exroute.d'
EXVPNROUTEDIR='/jffs/exvpnroute.d'
INFO="[INFO#${PID}]"
DEBUG="[DEBUG#${PID}]"
ERROR="[ERROR#${PID}]"

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnup.sh started" >> $LOG
for i in 1 2 3 4 5 6
do
	if [ -f $LOCK ]; then
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") got $LOCK , sleep 10 secs. #$i/6" >> $LOG
		sleep 10
	else
		break
	fi
done

if [ -f $LOCK ]; then
   echo "$ERROR $(date "+%d/%b/%Y:%H:%M:%S") still got $LOCK , I'm aborted. Fix me." >> $LOG
   exit 0
fi
#else
#	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $LOCK was released, let's continue." >> $LOG
#fi

# create the lock
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnup" >> $LOCK
	
	

OLDGW=$(nvram get wan_gateway)

case $1 in
	"pptp")
		# assume it to be a DD-WRT
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") router type: DD-WRT" >> $LOG
		VPNSRV=$(nvram get pptpd_client_srvip)
		VPNSRVSUB=$(nvram get pptpd_client_srvsub)
		#PPTPDEV=$(route -n | grep ^$VPNSRVSUB | awk '{print $NF}')
		PPTPDEV=$(route -n | grep ^${VPNSRVSUB%.[0-9]*} | awk '{print $NF}' | head -n 1)
		VPNGW=$(ifconfig $PPTPDEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
		;;
	"openvpn")
		VPNSRV=$(nvram get openvpncl_remoteip)
		#OPENVPNSRVSUB=$(nvram get OPENVPNd_client_srvsub)
		#OPENVPNDEV=$(route | grep ^$OPENVPNSRVSUB | awk '{print $NF}')
		OPENVPNDEV='tun0'
		VPNGW=$(ifconfig $OPENVPNDEV | grep -Eo "P-t-P:([0-9.]+)" | cut -d: -f2)
		;;
	*)
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") unknown vpnup.sh parameter,quit." >> $LOCK
		exit 1
esac



if [ $OLDGW == '' ]; then
	echo "$ERROR OLDGW is empty, is the WAN disconnected?" >> $LOG
	exit 0
else
	echo "$INFO OLDGW is $OLDGW" 
fi

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") make $VPNSRV gw $OLDGW"  >> $LOG
route add -host $VPNSRV gw $OLDGW
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") delete default gw $OLDGW"  >> $LOG
route del default gw $OLDGW

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") add default gw $VPNGW"  >> $LOG
route add default gw $VPNGW

if [ -f $IPTABLELOCK ]; then
  echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") static routes exists, skip." >> $LOG
else
# create the lock
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnup" >> $IPTABLELOCK

echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") adding the static routes, this may take a while." >> $LOG

# add cn routes
if [ ! -f $CNIPLIST ]; then
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") missing $CNIPLIST, wget it now."  >> $LOG
	wget http://autoddvpn-beta.googlecode.com/svn/trunk/cnips.lst -O $CNIPLIST 
fi
for i in $(grep -v ^# $CNIPLIST)
do
route add -net $i gw $OLDGW
done 

# prepare for the exceptional routes, see http://code.google.com/p/autoddvpn/issues/detail?id=7
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") preparing the exceptional routes" >> $LOG
if [ $(nvram get exroute_enable) -eq 1 ]; then
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") modifying the exceptional routes" >> $LOG
	if [ ! -d $EXROUTEDIR ]; then
		EXROUTEDIR='/tmp/exroute.d'
		mkdir $EXROUTEDIR
	fi
	for i in $(nvram get exroute_list)
	do
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") fetching exceptional routes for $i"  >> $LOG
		if [ -d $EXROUTEDIR -a ! -f $EXROUTEDIR/$i ]; then
			echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") missing $EXROUTEDIR/$i, wget it now."  >> $LOG
			wget http://autoddvpn.googlecode.com/svn/trunk/exroute.d/$i -O $EXROUTEDIR/$i 
		fi
		if [ ! -f $EXROUTEDIR/$i ]; then
			echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $EXROUTEDIR/$i not found, skip."  >> $LOG
			continue
		fi
		for r in $(grep -v ^# $EXROUTEDIR/$i)
		do
			echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") adding $r via wan_gateway"  >> $LOG
			# check the item is a subnet or a single ip address
			echo $r | grep "/" > /dev/null
			if [ $? -eq 0 ]; then
				route add -net $r gw $(nvram get wan_gateway) 
			else
				route add $r gw $(nvram get wan_gateway) 
			fi
		done 
	done
	#route | grep ^default | awk '{print $2}' >> $LOG
	# for custom list of exceptional routes
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") modifying custom exceptional routes if available" >> $LOG
	for i in $(nvram get exroute_custom)
	do
		echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") adding custom host/subnet $i via wan_gateway"  >> $LOG
		# check the item is a subnet or a single ip address
		echo $i | grep "/" > /dev/null
		if [ $? -eq 0 ]; then
			route add -net $i gw $(nvram get wan_gateway) 
		else
			route add $i gw $(nvram get wan_gateway) 
		fi
	done
else
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") exceptional routes disabled."  >> $LOG
	echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") exceptional routes features detail:  http://goo.gl/fYfJ"  >> $LOG
fi
fi

# prepare for the exceptional VPN routes
if [ $(nvram get exvpnroute_enable) -eq 1 ]; then
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") modifying the exceptional VPN routes" >> $LOG
for i in $(nvram get exvpnroute_list)
do
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") fetching exceptional VPN routes for $i"  >> $LOG
if [ ! -f $EXVPNROUTEDIR/$i ]; then
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") $EXVPNROUTEDIR/$i not found, skip."  >> $LOG
continue
fi
for r in $(grep -v ^# $EXVPNROUTEDIR/$i)
do
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") adding $r via VPN_gateway"  >> $LOG
# check the item is a subnet or a single ip address
echo $r | grep "/" > /dev/null
if [ $? -eq 0 ]; then
route add -net $r gw $VPNGW
else
route add $r gw $VPNGW
fi
done 
done
else
echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") exceptional VPN routes disabled, skip."  >> $LOG
fi

# final check again
echo "$INFO final check the default gw"
for i in 1 2 3 4 5 6
do
  GW=$(route -n | grep ^0.0.0.0 | awk '{print $2}')
  echo "$DEBUG my current gw is $GW"
  #route | grep ^default | awk '{print $2}'
  if [ "$GW" == "$OLDGW" ]; then
    echo "$DEBUG still got the OLDGW, why?"
    echo "$INFO delete default gw $OLDGW"
    route del default gw $OLDGW
    echo "$INFO add default gw $VPNGW again"
    route add default gw $VPNGW
    sleep 3
  else
    break
  fi
done
GW=$(route -n | grep ^0.0.0.0 | awk '{print $2}')
if [ "$GW" == "$OLDGW" ]; then
  echo "$ERROR $(date "+%d/%b/%Y:%H:%M:%S") still got the old gw, it may because vpn was disconnected." >> $LOG
  echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnup.sh ended" >> $LOG
else
  echo "$INFO static routes added"
  echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") vpnup.sh ended" >> $LOG
  echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") restarting DNSMasq service" >> $LOG
  stopservice dnsmasq
  startservice dnsmasq
  echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") restarting DNS" >> $LOG
  restart_dns
fi
# release the lock
rm -f $LOCK

# run checkvpn
if [ -f $CHECKVPNLOCK ]; then
    echo "$DEBUG checkvpn program is running in background"
else
    echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") checkvpn running" >> $CHECKVPNLOCK
    if [ -f '/jffs/pptp/checkvpn.sh' ]; then
        echo "$INFO $(date "+%d/%b/%Y:%H:%M:%S") run checkvpn program in background" >> $LOG
        nohup /jffs/pptp/checkvpn.sh > /dev/null &
    else
        echo "$ERROR $(date "+%d/%b/%Y:%H:%M:%S") checkvpn program not found" >> $LOG
    fi
fi

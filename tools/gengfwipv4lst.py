#!/usr/bin/env python

import urllib
import base64
import string
import dns.resolver
import re

# modified by Shujenchang from http://autoddvpn.googlecode.com/svn/trunk/grace.d/gfwListgen.py

gfwlist = 'http://autoproxy-gfwlist.googlecode.com/svn/trunk/gfwlist.txt'
# some sites can be visited via https or is already in known list
oklist = ['flickr.com', 'wikia.com', 'wikimedia.org', 'wikipedia.org', 'wikisource.org', 'wikinews.org', 'wiktionary.org', 'wikiquote.org', 'wikibooks.org', 'wikiversity.org', 'wikivoyage.org', 'wikidata.org', 'mediawiki.org']
print "fetching gfwList ..."
d = urllib.urlopen(gfwlist).read()
#d = open('gfwlist.txt').read()
data = base64.b64decode(d)
#fd = open('gfwlist','w')
#fd.write(data)
#fd.close()
lines = string.split(data, "\n")
newlist = []

def isipaddr(hostname=''):
	pat = re.compile(r'[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+')
	if re.match(pat, hostname):
		return 0
	else:
		return -1

def getip(hostname=''):
	_ip = []
	if isipaddr(hostname) == 0:
		print hostname + " is IP address"
		_ip.append(hostname)
		return
	r = dns.resolver.get_default_resolver()
	r.nameservers=['8.8.8.8']
	#answers = dns.resolver.query(hostname, 'A')
	try:
		answers = r.query(hostname, 'A')
		for rdata in answers:
			print rdata.address
			_ip.append(rdata.address)
	except dns.resolver.NoAnswer:
		print "no answer"

	if hostname.find("www.") != 0:
		hostname = "www."+hostname
		print "querying "+hostname
		try:
			answers = dns.resolver.query(hostname, 'A')
			for rdata in answers:
				print rdata.address
				_ip.append(rdata.address)
		except dns.resolver.NoAnswer:
			print "no answer"
		
	return list(set(_ip))

inoklist = -1

for l in lines:
		if len(l) == 0:
			continue
		if l[0] == "!":
			continue
		if l[0] == "|":
			continue
		if l[0] == "@":
			continue
		if l[0] == "[":
			continue
		l = string.replace(l, "||","").lstrip(".")
		# strip everything from "/" to the end
		if l.find("/") != -1:
			l = l[0:l.find("/")]
		if l.find("%2F") != -1:
			continue
		if l.find("*") != -1:
			continue
		if l.find(".") == -1:
			continue
		for k in oklist:
			if l.find(k) != -1:
				inoklist = 0
				break
		if inoklist == 0:
			inoklist = -1
			continue
		newlist.append(l)

newlist = list(set(newlist))
newlist.sort()

ip = []

# generate dnsmasq configuration & resolve IP address
gfwdn = open('gfwdomains.conf', 'wa')
for l in oklist:
	gfwdn.write('server=/'+l+'/8.8.8.8\n')
for l in newlist:
	if isipaddr(l) != 0:
		print l
		gfwdn.write('server=/'+l+'/8.8.8.8\n')
		try:
			myip = getip(l)
			ip+=myip
		except:
			continue

gfwdn.close()

iplist = list(set(ip))
iplist.sort()

#print ip
#ipfd = open("ip-list","wa")
#for i in iplist:
	#print i
	#ipfd.write(i+"\n")
#ipfd.close()

subnetdir={}
for ip in iplist:
	(a,b,c,d) = string.split(ip, ".")
	subnet = a+"."+b+"."+c+".0"
	if subnetdir.has_key(subnet):
		subnetdir[subnet]+=1
	else:
		subnetdir[subnet]=1

msubnet=[]
for subnet in subnetdir.keys():
	if subnetdir[subnet]>1:
		msubnet.append(subnet)
		#print subnet+"/24"

ipaddrlist = []
for ip in iplist:
	(a,b,c,d) = string.split(ip, ".")
	_subnet = a+"."+b+"."+c+".0"
	if _subnet in msubnet:
		print "%s is in subnet %s" % (ip, _subnet)
	else:
		print "%s has no subnet available" % (ip)
		ipaddrlist.append(ip)

ipaddrlist.sort()
msubnet.sort()

gfwiplist="http://autoddvpn-beta.googlecode.com/svn/trunk/gfwips.lst"

listfile=open('gfwips.lst','wa')

uplines = urllib.urlopen(gfwiplist).readlines()
#uplines = open('vpnup-grace.sh').readlines()

_anchor=0
for l in uplines:
	#if _anchor==0:	print l.rstrip()
	if _anchor==0:	listfile.write(l)
	if l.find('all others') != -1:
		break

print "[INFO] generating the routes"
cnt=0
for i in ipaddrlist:
	buff = "%s" % i
	print buff
	listfile.write(buff+'\n')
	cnt+=1
for m in msubnet:
	buff = "%s/24" % m
	print buff
	listfile.write(buff+'\n')
	cnt+=1
print "[INFO] total %i routes generated" % (cnt)

listfile.close()

print "[INFO] ALL DONE"

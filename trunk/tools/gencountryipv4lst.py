#!/usr/bin/env python
# This is the tool generating the IPv4 addresses list in a defined country according to the APNIC database
# modified by Shujenchang from http://chnroutes.googlecode.com/svn/trunk/chnroutes.py

import urllib
import urllib2
import string
import re
import math

#ipv4url='http://ftp.apnic.net/apnic/dbase/data/country-ipv4.lst'
#ipv4url='http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest'

# change xx to the ISO 3166-1 alpha-2 country code of the defined country
listfile=open('xxips','wa')

def fetch_ip_data():
  #fetch data from apnic
  print "Fetching data from apnic.net, it might take a few minutes, please wait..."
  url=r'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest'
  data=urllib2.urlopen(url).read()
  
  # change xx to the ISO 3166-1 alpha-2 country code of the defined country
  ipregex=re.compile(r'apnic\|xx\|ipv4\|[0-9\.]+\|[0-9]+\|[0-9]+\|a.*',re.IGNORECASE)
  
  ipdata=ipregex.findall(data)
  
  results=[]

  for item in ipdata:
      unit_items=item.split('|')
      starting_ip=unit_items[3]
      num_ip=int(unit_items[4])
      
      imask=0xffffffff^(num_ip-1)
      #convert to string
      imask=hex(imask)[2:]
      mask=[0]*4
      mask[0]=imask[0:2]
      mask[1]=imask[2:4]
      mask[2]=imask[4:6]
      mask[3]=imask[6:8]
      
      #convert str to int
      mask=[ int(i,16 ) for i in mask]
      mask="%d.%d.%d.%d"%tuple(mask)
      
      #mask in *nix format
      mask2=32-int(math.log(num_ip,2))
      
      results.append((starting_ip,mask,mask2))
       
  return results


def main():

	print "[INFO] generating the routes"
	cnt=0
	results = fetch_ip_data()
	for ip,mask,mask2 in results:
		listfile.write("%s/%s\n" % (ip, mask2))
		cnt+=1

	listfile.close()
	print "[INFO] total %i routes generated" % (cnt)
	print "[INFO] ALL DONE"

if __name__ == '__main__':
	main()

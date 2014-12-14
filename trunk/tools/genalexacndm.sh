#!/bin/sh
# This is the tool generating the DNSMasq configuration file optimizing the visit for websites inside China according to Alexa Top Sites
# from http://code.google.com/p/autoddvpn/wiki/DNSMasq

# change this to your Chinese ISP DNS server address
ispdns='202.96.209.5'

for i in 0 1 2 3 4
do
    curl -s "http://www.alexa.com/topsites/countries;$i/CN" | grep "small topsites-label"  | \
    sed -e "s#.*>\([^ ]*\)<.*#server=/\1/$ispdns#g"
done

#!/bin/sh
# 
# dhcpactiv.sh
#
# v.004
# - rewritten again to pull data from dhcpd files according to labels instead of position
#
# v.003
# - add code to remove tstp information from dpcpd.leases
#
# v.002 
# - rewritten to use awk more for parsing
# - added "GMT" indicator to Expiration col head
#
echo "Source        Host       MAC Address       IP Address      Expiration (GMT)"
echo "============= ========== ================= =============== ================"
#
awk ' { out = ""} \
      { $1=="lease"||$1=="client-hostname" ? out=" " $2 : out=out } \
      { $1=="binding"||$1=="hardware" ? out= " " $3: out=out } \
      { $1=="ends"? out=" " $3 " " $4: out=out } \
      { $1=="}"? out="\n": out=out } \
      { printf out," " }' /var/lib/dhcpd/dhcpd.leases \
  | grep active \
  | sed -e s/'[{};" ]'/\ /g  \
  | awk '{ printf "%-13s %-10s %-17s %-15s %-10s %-5s\n", "dhcpd.leases", $6, $5, $1, $2, $3 }' 

#
# Now do the same for /etc/dhcpd.conf
#
 awk ' { out = ""} 
       { $1=="host"||$1=="fixed-address" ? out=" " $2 : out=out } \
       { $1=="hardware" ? out= " " $3: out=out } \
       { $1=="}"? out="\n": out=out } \
       { printf out," " }' /etc/dhcpd.conf \
  | grep : \
  | sed -e  s/'[{};\" ]'/\ /g -e  s/\.`config get DomainName`// \
  | awk  '{ printf "%-13s %-10s %-17s %-15s %-15s \n", "dhcpd.conf", $1, $2, $3, "reservation"}'
#
# Finally, grab the current arp table
#
arp -a \
  |  sed -e s/\\..*\(/\ / -e s/\)// \
  |  awk '{ printf "%-13s %-10s %-17s %-15s %-15s \n", "arp", $1, $4, $2, "n/a"}'

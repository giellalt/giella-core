#!/bin/bash
#service monitoring
/bin/netstat -tulpn 2>/dev/null | awk '{print $4}' | awk -F: '{print $4}' | grep ^8080$ > /dev/null
a=$(echo $?)
if test $a -ne 0
then
    echo "eXist service down" | mail -s "eXist service down and restarted now" tomi.k.pieski@uit.no,borre.gaup@uit.no,sjur.n.moshagen@uit.no
    /etc/init.d/eXist-db start > /dev/null 2>/dev/null
else
    sleep 0
fi

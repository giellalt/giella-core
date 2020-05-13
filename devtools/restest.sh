#!/bin/bash
#testing rest interface
curl -v --silent http://gtweb.uit.no:8080/exist/restxq/satni/dictionaries 2>&1 | grep 'HTTP/1.1 [0-9]' | awk '{print $3}' | grep ^200$ > /dev/null
a=$(echo $?)
if test $a -ne 0
then
    echo "GET /dictionaries fails" | mail -s "REST service seems to be down" tomi.k.pieski@uit.no,borre.gaup@uit.no,sjur.n.moshagen@uit.no
else
    sleep 0
fi

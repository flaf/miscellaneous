#!/bin/sh

export LC_ALL=C
export PATH='/usr/bin:/bin'

url="$1"
shift

i=1
for arg in "$@"
do
    arg=$(printf "%s" "$arg" | /bin/sed "s/'/'\"'\"'/g")
    options="$options -d 'token$i=$arg'"
    i=$((i+1))
done

eval "/usr/bin/curl --silent $options http://$url"



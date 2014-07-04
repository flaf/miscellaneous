#!/bin/sh

export LC_ALL=C
export PATH='/usr/bin:/bin'

url="$1"
shift

c='1'
options=''

for token in "$@"
do
    options="$options -d 'token$c=$token'"
    c=$((c+1))
done

curl $options "http://$url"



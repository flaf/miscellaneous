#!/bin/sh

export LC_ALL=C
export PATH='/usr/bin:/bin'

url="$1"
shift

for token in $@
do
    echo "[$token]"
done



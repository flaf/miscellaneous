#!/bin/sh

export PATH='/usr/sbin:/usr/bin:/sbin:/bin'
export LC_ALL='C'

if [ "$(id -un)" != 'root' ]
then
   printf "This command must be run as root.\n"
   exit 1
fi

service gammu-smsd stop
sleep 1

printf "Now, USB restart...\n"

SYSUHCI=/sys/bus/pci/drivers/uhci_hcd
if cd "$SYSUHCI" 2>/dev/null
then
    for i in ????:??:??.?
    do
       printf "$i" > unbind
       sleep 0.5
       printf "$i" > bind
    done
else
    printf "No directory $SYSUHCI.\n"
fi

SYSEHCI=/sys/bus/pci/drivers/ehci_hcd
if cd $SYSEHCI 2>/dev/null
then
    for i in ????:??:??.?
    do
       printf "$i" > unbind
       sleep 0.5
       printf "$i" > bind
    done
else
    printf "No directory $SYSEHCI.\n"
fi

sleep 1
service gammu-smsd start


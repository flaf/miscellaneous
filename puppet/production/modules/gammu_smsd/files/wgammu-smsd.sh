#!/bin/sh

export PATH='/usr/sbin:/usr/bin:/sbin:/bin'
export LC_ALL='C'

if [ "$(id -un)" != 'root' ]
then
   printf "This command must be run as root.\n"
   exit 1
fi

cmd="$1"

disconnect_reconnect_usb () {

    printf "Disconnect and reconnect USB...\n"

    SYSUHCI=/sys/bus/pci/drivers/uhci_hcd
    if cd "$SYSUHCI" 2>/dev/null
    then
        printf "Directory $SYSUHCI found.\n"
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
        printf "Directory $SYSEHCI found.\n"
        for i in ????:??:??.?
        do
           printf "$i" > unbind
           sleep 0.5
           printf "$i" > bind
        done
    else
        printf "No directory $SYSEHCI.\n"
    fi

}

sleep_fct () {

    printf "Sleeping during $1 second(s)...\n"
    sleep "$1"

}

case $cmd in

    start|restart)
        service gammu-smsd stop
        sleep_fct 5
        disconnect_reconnect_usb
        sleep_fct 20
        service gammu-smsd start
        sleep_fct 5
        exit 0
    ;;

    stop)
        service gammu-smsd stop
        sleep_fct 5
        exit 0
    ;;

    status)
        if ps -e -o comm | grep -q '^gammu-sms[d]'
        then
            printf "gammu-smsd is running...\n"
            exit 0
        else
            printf "gammu-smsd is not running...\n"
            exit 1
        fi
    ;;

    *)
        printf "Sorry, valid commands are start, stop, restart and status.\n"
        exit 1
    ;;

esac


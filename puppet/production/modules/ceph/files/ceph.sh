#!/bin/sh
### This file is managed by Puppet, don't edit it ###

SCRIPT_NAME="${0##*/}"
export LC_ALL='C'
export PATH='/usr/sbin:/usr/bin:/sbin:/bin'

COMMON_SYNOPSIS="--cluster <cluster>"
COMMON_SHORT_OPTIONS='h,c:'
COMMON_LONG_OPTIONS='help,cluster:'

print_help () {
    cat <<EOF
The syntax is:
    $SCRIPT_NAME --help
    $SCRIPT_NAME $COMMON_SYNOPSIS $SPECIFIC_SYNOPSIS
EOF
}

if ! TEMP=$(getopt -o "$COMMON_SHORT_OPTIONS,$SPECIFIC_SHORT_OPTIONS" \
                   -l "$COMMON_LONG_OPTIONS,$SPECIFIC_LONG_OPTIONS"   \
                   -n "$SCRIPT_NAME" -- "$@")
then
    echo "Syntax error with $SCRIPT_NAME command." >&2
    print_help
    exit '1'
fi

eval set -- "$TEMP"
unset TEMP

while true
do
    case "$1" in
        --cluster|-c)
            cluster="$2"
            shift 2
        ;;

        --help|-h)
            print_help
            exit "$CODE_OK"
        ;;

        --)
            shift 1
            break
        ;;

        *)
            GET_SPECIFIC_OPTIONS "$1" "$2" || shift "$?"
        ;;
    esac
done

if [ -z "$cluster" ]
then
    echo "You must provide the cluster name with the --cluster option."
    exit 1
fi



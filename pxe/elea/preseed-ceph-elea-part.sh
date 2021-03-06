#!/bin/sh

if [ "$1" = 'install-grub' ]
then
    # Grub just in /dev/sda because no RAID soft.
    for device in /dev/sda
    do
        for symlink in /dev/disk/by-id/*
        do
            if [ "$device" = "$(readlink -f $symlink)" ]
            then
                device_id="$symlink"
            fi
        done

        if [ -z "$device_grub_target" ]
        then
            device_grub_target="$device_id"
        else
            device_grub_target="$device_grub_target, $device_id"
        fi

    done

    printf "grub-pc grub-pc/install_devices multiselect %s\n" "$device_grub_target" >/target/tmp/debconf.grub

    mount --bind /dev/pts /target/dev/pts
    mount --bind /proc    /target/proc
    mount --bind /sys     /target/sys

    # I don't know why but if I use `chroot /target ...` instead of
    # `in-target`, it doesn't work.
    in-target /bin/bash -c 'debconf-set-selections </tmp/debconf.grub >>/tmp/log 2>&1'
    in-target /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install --yes grub-pc >>/tmp/log 2>&1'

    umount /target/dev/pts
    umount /target/proc
    umount /target/sys
    exit 0
fi



exec >/tmp/part.log 2>&1
set -x

parted='parted --script --align=opt'

$parted /dev/sda mktable gpt

part_num=1

# The unused UEFI partition if one day we decide
# to enable the Bios-UEFI.
# I don't know why but, _during the Trusty installation_
# if I set a == 1 (MiB) the partition not begins at 1 MiB
# but at 0.25MiB (for me it's a bug in the Trusty debian-installer).
# If I use 2048s instead, it works (???).
a=2048s
b=$((250 + 1)) # Size == 250MiB
$parted /dev/sda unit MiB mkpart uefiunused $a $b
part_num=$((part_num + 1))


# The biosgrub partition.
a=$b
b=$((1 + a)) # Size == 1MiB
$parted /dev/sda unit MiB mkpart biosgrub $a $b
$parted /dev/sda set $part_num bios_grub on
part_num=$((part_num + 1))


# The root partition.
a=$b
b=$((20 * 1024 + a)) # Size == 20GiB
$parted /dev/sda unit MiB mkpart system $a $b
part_num=$((part_num + 1))


# The swap.
a=$b
b=$((8 * 1024 + a)) # Size == 8GiB
$parted /dev/sda unit MiB mkpart swap linux-swap $a $b
part_num=$((part_num + 1))


### Creation of the file systems. ###

mkfs.ext4 -F -E lazy_itable_init=0 -L system /dev/sda3
mkswap -L swap /dev/sda4



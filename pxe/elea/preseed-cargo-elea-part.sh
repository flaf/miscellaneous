#!/bin/sh

if [ "$1" = 'install-grub' ]
then
    # Grub just in /dev/sdb because no RAID soft.
    for device in /dev/sdb
    do
        # Unfortunately, the stat command is not available
        # during the Debian installation.
        inode_device=$(ls -i $device)
        inode_device=$(echo $inode_device | cut -d' ' -f1)
        for symlink in $(find -L /dev/disk/by-id/ -inum "$inode_device")
        do
            device_id="$symlink"
        done

        if [ -z "$device_grub_target" ]
        then
            device_grub_target="$symlink"
        else
            device_grub_target="$device_grub_target, $symlink"
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

$parted /dev/sdb mktable gpt

part_num=1

# The unused UEFI partition if one day we decide
# to enable the Bios-UEFI.
a=1
b=$((250 + a)) # Size == 250MiB
$parted /dev/sdb unit MiB mkpart uefiunused $a $b
part_num=$((part_num + 1))


# The biosgrub partition.
a=$b
b=$((1 + a)) # Size == 1MiB
$parted /dev/sdb unit MiB mkpart biosgrub $a $b
$parted /dev/sdb set $part_num bios_grub on
part_num=$((part_num + 1))


# The root partition.
a=$b
b=$((30 * 1024 + a)) # Size == 30GiB
$parted /dev/sdb unit MiB mkpart system $a $b
part_num=$((part_num + 1))


# The swap.
a=$b
b=$((8 * 1024 + a)) # Size == 8GiB
$parted /dev/sdb unit MiB mkpart swap linux-swap $a $b
part_num=$((part_num + 1))


### Creation of the file systems. ###

mkfs.ext4 -F -E lazy_itable_init=0 -L system /dev/sdb3
mkswap -L swap /dev/sdb4



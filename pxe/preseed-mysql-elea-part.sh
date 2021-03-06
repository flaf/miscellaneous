#!/bin/sh

if [ "$1" = 'install-grub' ]
then

    for device in /dev/sda /dev/sdb
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

raid1system='md0'
raid1swap='md1'
raid1ssd='md2'


### Remove the RAID volumes /dev/$raid1system and /dev/$raid1swap if already created. ###
[ -e /dev/$raid1system ] && mdadm --stop /dev/$raid1system
[ -e /dev/$raid1swap ] && mdadm --stop /dev/$raid1swap
[ -e /dev/$raid1ssd ] && mdadm --stop /dev/$raid1ssd
mdadm --zero-superblock /dev/sda3
mdadm --zero-superblock /dev/sdb3
mdadm --zero-superblock /dev/sda4
mdadm --zero-superblock /dev/sdb4
mdadm --zero-superblock /dev/sdc1
mdadm --zero-superblock /dev/sdd1


### Create GPT partition on each disk. ###
for i in a b
do
    $parted /dev/sd${i} mktable gpt
done


### Partitioning on the non-SSD drives. ###
n=0
for i in a b
do
    # a => n = 1, b => n = 2.
    n=$((n + 1))

    part_num=1

    # The used UEFI partitions if one day we decide
    # to enable the Bios-UEFI.
    a=1
    b=$((250 + a)) # Size == 250MiB
    $parted /dev/sd${i} unit MiB mkpart uefi${n}unused $a $b
    part_num=$((part_num + 1))

    # The biosgrub partitions.
    a=$b
    b=$((1 + a)) # Size == 1MiB
    $parted /dev/sd${i} unit MiB mkpart biosgrub${n} $a $b
    $parted /dev/sd${i} set $part_num bios_grub on
    part_num=$((part_num + 1))

    # The root partitions (will be a RAID1 volume).
    a=$b
    b=$((6 * 1024 + a)) # Size == 6GiB
    $parted /dev/sd${i} unit MiB mkpart system${n} $a $b
    $parted /dev/sd${i} set $part_num raid on
    part_num=$((part_num + 1))

    # The swap (will be a RAID1 volume).
    a=$b
    b=$((1 * 1024 + a)) # Size == 1GiB
    $parted /dev/sd${i} unit MiB mkpart swap${n} linux-swap $a $b
    $parted /dev/sd${i} set $part_num raid on
    part_num=$((part_num + 1))

done


### Creation of the RAID volumes. ###

# For the system (/) partition.
mdadm --create /dev/$raid1system --level=1 --raid-devices=2 /dev/sda3 /dev/sdb3 --force --run

# For the swap partition.
mdadm --create /dev/$raid1swap --level=1 --raid-devices=2 /dev/sda4 /dev/sdb4 --force --run

# The SSD RAID1 volume.
mdadm --create /dev/$raid1ssd --level=1 --raid-devices=2 /dev/sdc1 /dev/sdd1 --force --run


### Creation of the file systems. ###

mkfs.ext4 -F -E lazy_itable_init=0 -L system /dev/$raid1system
mkswap -L swap /dev/$raid1swap



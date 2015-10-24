#!/bin/sh

if [ "$1" = 'install-grub' ]
then

    for device in /dev/sda
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

    mount --bind /dev/pts /target/dev/pts
    mount --bind /proc    /target/proc
    mount --bind /sys     /target/sys

    # I don't know why but if I use `chroot /target ...` instead of
    # `in-target`, it doesn't work.
    in-target /bin/bash -c 'DEBIAN_FRONTEND=noninteractive apt-get install --yes grub-efi-amd64 >>/tmp/log 2>&1'
    in-target /bin/bash -c 'update-grub >>/tmp/log 2>&1'
    in-target /bin/bash -c 'grub-install --target=x86_64-efi -efi-directory=/boot/efi --bootloader-id=debian --recheck /dev/sda >>/tmp/log 2>&1'

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
for i in a b c d
do
    $parted /dev/sd${i} mktable gpt
done


### Partitioning on the non-SSD drives. ###
n=0
for i in a
do
    # a => n = 1, b => n = 2.
    n=$((n + 1))

    part_num=1

    # The used UEFI partitions if one day we decide
    # to enable the Bios-UEFI.
    a=1
    b=$((250 + a)) # Size == 250MiB
    $parted /dev/sd${i} unit MiB mkpart uefi${n} $a $b
    $parted /dev/sd${i} set $part_num esp on
    part_num=$((part_num + 1))

    # The root partitions (will be a RAID1 volume).
    a=$b
    b=$((30 * 1024 + a)) # Size == 30GiB
    $parted /dev/sd${i} unit MiB mkpart system${n} $a $b
    part_num=$((part_num + 1))

    # The swap (will be a RAID1 volume).
    a=$b
    b=$((8 * 1024 + a)) # Size == 64GiB
    $parted /dev/sd${i} unit MiB mkpart swap${n} linux-swap $a $b
    part_num=$((part_num + 1))

done




# To be sure that the partitions /dev/sda[1-9] are created.
sleep 2

### Creation of the file systems. ###

# mkfs.vfat doesn't exist during Debian installation.
# Lowercase labels trigger a warning.
mkfs.fat -F 32 -n 'UEFI' /dev/sda1

mkfs.ext4 -F -E lazy_itable_init=0 -L system /dev/sda2
mkswap -L swap /dev/sda3



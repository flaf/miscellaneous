#!/bin/sh

exec >/tmp/part.log 2>&1
parted='parted --script --align=opt'

# Remove the RAID volumes /dev/md0 and /dev/md1 if already created.
if [ -e /dev/md0 ]
then
    mdadm --stop /dev/md0
    mdadm --zero-superblock /dev/sda2
    mdadm --zero-superblock /dev/sdb2
fi
if [ -e /dev/md1 ]
then
    mdadm --stop /dev/md1
    mdadm --zero-superblock /dev/sda3
    mdadm --zero-superblock /dev/sdb3
fi

# Create GPT partition on each disk.
for i in a b c d
do
    $parted /dev/sd${i} mktable gpt
done

# Partitioning on the non-SSD drives.
for i in a b
do

    # The biosgrub partitions.
    $parted /dev/sd${i} unit MiB mkpart biosgrub${i} 1 2
    $parted /dev/sd${i} set 1 bios_grub on

    # The root partitions (will be a RAID1 volume).
    a=2
    b=$((30 * 1024 + a))
    $parted /dev/sd${i} unit MiB mkpart system${i} $a $b
    $parted /dev/sd${i} set 2 raidb on

    # The swap (will be a RAID1 volume).
    a=$b
    b=$((64 * 1024 + a))
    $parted /dev/sd${i} unit MiB mkpart swap linux-swap $a $b

done



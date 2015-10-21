#!/bin/sh

exec >/tmp/part.log 2>&1
set -x

parted='parted --script --align=opt'

### Remove the RAID volumes /dev/md0 and /dev/md1 if already created. ###
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
if [ -e /dev/md2 ]
then
    mdadm --stop /dev/md2
    mdadm --zero-superblock /dev/sdc1
    mdadm --zero-superblock /dev/sdd1
fi


### Create GPT partition on each disk. ###
for i in a b c d
do
    $parted /dev/sd${i} mktable gpt
done


### Partitioning on the non-SSD drives. ###
n=0
for i in a b
do
    # a => n = 1, b => n = 2.
    n=$((n + 1))

    # The used UEFI partitions if one day we decide
    # to enable the Bios-UEFI.
    a=1
    b=250 # Size == 250MiB
    $parted /dev/sd${i} unit MiB mkpart uefi${n}unused $a $b

    # The biosgrub partitions.
    a=$b
    b=$((1 + $b)) # Size == 1MiB
    $parted /dev/sd${i} unit MiB mkpart biosgrub${n} $a $b
    $parted /dev/sd${i} set 1 bios_grub on

    # The root partitions (will be a RAID1 volume).
    a=$b
    b=$((30 * 1024 + a)) # Size == 30GiB
    $parted /dev/sd${i} unit MiB mkpart system${n} $a $b
    $parted /dev/sd${i} set 2 raid on

    # The swap (will be a RAID1 volume).
    a=$b
    b=$((64 * 1024 + a)) # Size == 64GiB
    $parted /dev/sd${i} unit MiB mkpart swap${n} linux-swap $a $b

done


### Partitioning on the SSD drives. ###
n=0
for i in c d
do
    # c => n = 1, d => n = 2.
    n=$((n + 1))

    # The swap (will be a RAID1 volume).
    a=1
    b='-1s' # The last sector
    $parted /dev/sd${i} -- unit MiB mkpart ssd${n} $a $b
done


### Creation of the RAID volumes. ###

# For the system (/) partition.
mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sda2 /dev/sdb2

# For the swap partition.
mdadm --create /dev/md1 --level=1 --raid-devices=2 /dev/sda3 /dev/sdb3

# The SSD RAID1 volume.
mdadm --create /dev/md2 --level=1 --raid-devices=2 /dev/sdc1 /dev/sdd1


### Creation of the volume group LVM on the SSD RAID1 volume. ###

pvcreate --force /dev/md2
vgcreate --force --yes vg1 /dev/md2


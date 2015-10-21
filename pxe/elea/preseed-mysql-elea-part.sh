#!/bin/sh

exec >/tmp/part.log 2>&1
set -x

parted='parted --script --align=opt'

### Remove the RAID volumes /dev/md0 and /dev/md1 if already created. ###
[ -e /dev/md0 ] && mdadm --stop /dev/md0
[ -e /dev/md1 ] && mdadm --stop /dev/md1
[ -e /dev/md2 ] && mdadm --stop /dev/md2
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
for i in a b
do
    # a => n = 1, b => n = 2.
    n=$((n + 1))

    part_num=1

    # The used UEFI partitions if one day we decide
    # to enable the Bios-UEFI.
    a=1
    b=250 # Size == 250MiB
    $parted /dev/sd${i} unit MiB mkpart uefi${n}unused $a $b
    part_num=$((part_num + 1))

    # The biosgrub partitions.
    a=$b
    b=$((1 + $b)) # Size == 1MiB
    $parted /dev/sd${i} unit MiB mkpart biosgrub${n} $a $b
    $parted /dev/sd${i} set $part_num bios_grub on
    part_num=$((part_num + 1))

    # The root partitions (will be a RAID1 volume).
    a=$b
    b=$((30 * 1024 + a)) # Size == 30GiB
    $parted /dev/sd${i} unit MiB mkpart system${n} $a $b
    $parted /dev/sd${i} set $part_num raid on
    part_num=$((part_num + 1))

    # The swap (will be a RAID1 volume).
    a=$b
    b=$((64 * 1024 + a)) # Size == 64GiB
    $parted /dev/sd${i} unit MiB mkpart swap${n} linux-swap $a $b
    $parted /dev/sd${i} set $part_num raid on
    part_num=$((part_num + 1))

done


### Partitioning on the SSD drives. ###
n=0
for i in c d
do
    # c => n = 1, d => n = 2.
    n=$((n + 1))

    # The swap (will be a RAID1 volume).
    a=1
    b='-1cyl' # The last cylinder
    $parted /dev/sd${i} -- unit MiB mkpart ssd${n} $a $b
done


### Creation of the RAID volumes. ###

# For the system (/) partition.
mdadm --create /dev/md0 --level=1 --raid-devices=2 /dev/sda3 /dev/sdb3 --force --run

# For the swap partition.
mdadm --create /dev/md1 --level=1 --raid-devices=2 /dev/sda4 /dev/sdb4 --force --run

# The SSD RAID1 volume.
mdadm --create /dev/md2 --level=1 --raid-devices=2 /dev/sdc1 /dev/sdd1 --force --run


### Creation of the volume group LVM on the SSD RAID1 volume. ###

pvcreate --force --ff /dev/md2
vgcreate --force --yes vg1 /dev/md2



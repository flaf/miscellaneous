#!/bin/sh

if [ "$1" = 'install-grub' ]
then

    for device in /dev/sda /dev/sdb
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


if [ "$1" = 'post-install' ]
then
    exec >/root/post-install.log 2>&1
    set -x

    # Puppet, puppet, puppet...
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --yes lsb-release

    # I don't why but this doesn't work in the /taget chroot.
    # But it's works well in a classical command line.
    #KEY='47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30'
    #apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$KEY"

    wget http://apt.puppetlabs.com/pubkey.gpg -O - | apt-key add -

    COLLECTION='PC1'
    distrib=$(lsb_release -sc)
    collection=$(echo $COLLECTION | tr '[:upper:]' '[:lower:]')
    cat >/etc/apt/sources.list.d/puppetlabs-$collection.list <<EOF
# Puppetlabs $COLLECTION $distrib Repository.
deb http://apt.puppetlabs.com $distrib $COLLECTION
#deb-src http://apt.puppetlabs.com $distrib $COLLECTION
EOF
    # Force the version number as below.
    apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install --yes puppet-agent=1.2.7-*

    server='moopuppet.dc2.backbone.education'
    ca_server='puppet.lss1.backbone.education'
    echo "#/opt/puppetlabs/bin/puppet agent --test --server=$server --ca_server=$ca_server" >> /root/.bash_history
    chown root:root /root/.bash_history
    chmod 600 /root/.bash_history

    # Allow ssh with root.
    sed -i 's/^PermitRootLogin[[:space:]].*/PermitRootLogin yes/' /etc/ssh/sshd_config

    exit 0
fi



exec >/tmp/part.log 2>&1
set -x

parted='parted --script --align=opt'

### Remove the RAID volumes if already created. ###

i='3' # on /dev/sda3 and /dev/sdb3
raid1system='md0'
[ -e /dev/$raid1system ] && mdadm --stop /dev/$raid1system
[ -e /dev/sda$i ]        && mdadm --zero-superblock /dev/sda$i
[ -e /dev/sdb$i ]        && mdadm --zero-superblock /dev/sdb$i

i='4' # on /dev/sda4 and /dev/sdb4
raid1swap='md1'
[ -e /dev/$raid1swap ] && mdadm --stop /dev/$raid1swap
[ -e /dev/sda$i ]      && mdadm --zero-superblock /dev/sda$i
[ -e /dev/sdb$i ]      && mdadm --zero-superblock /dev/sdb$i

i='5' # on /dev/sda5 and /dev/sdb5
raid1hd='md2'
[ -e /dev/$raid1hd ] && mdadm --stop /dev/$raid1hd
[ -e /dev/sda$i ]    && mdadm --zero-superblock /dev/sda$i
[ -e /dev/sdb$i ]    && mdadm --zero-superblock /dev/sdb$i

i='1' # on /dev/sdc1 and /dev/sdd1
raid1ssd='md3'
[ -e /dev/$raid1ssd ] && mdadm --stop /dev/$raid1ssd
[ -e /dev/sdc$i ]     && mdadm --zero-superblock /dev/sdc$i
[ -e /dev/sdd$i ]     && mdadm --zero-superblock /dev/sdd$i


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

    # The unused UEFI partitions if one day we decide
    # to enable the Bios-UEFI.
    a=1
    b=$((250 + a)) # Size == 250MiB
    $parted /dev/sd${i} -- unit MiB mkpart uefi${n}unused $a $b
    part_num=$((part_num + 1))

    # The biosgrub partitions.
    a=$b
    b=$((1 + a)) # Size == 1MiB
    $parted /dev/sd${i} -- unit MiB mkpart biosgrub${n} $a $b
    $parted /dev/sd${i} set $part_num bios_grub on
    part_num=$((part_num + 1))

    # The root partitions (will be a RAID1 volume).
    a=$b
    b=$((30 * 1024 + a)) # Size == 30GiB
    $parted /dev/sd${i} -- unit MiB mkpart system${n} $a $b
    $parted /dev/sd${i} set $part_num raid on
    part_num=$((part_num + 1))

    # The swap (will be a RAID1 volume).
    a=$b
    b=$((8 * 1024 + a)) # Size == 8GiB
    $parted /dev/sd${i} -- unit MiB mkpart swap${n} linux-swap $a $b
    $parted /dev/sd${i} set $part_num raid on
    part_num=$((part_num + 1))

    # The remaining of the disk is a LVM partition in a RAID1 volume.
    a=$b
    b='-1cyl' # The last cylinder
    $parted /dev/sd${i} -- unit MiB mkpart lvm-hd${n} $a $b
    $parted /dev/sd${i} set $part_num raid on
    part_num=$((part_num + 1))

done


### Partitioning on the SSD drives. ###
n=0
for i in c d
do
    # c => n = 1, d => n = 2.
    n=$((n + 1))

    # The LVM partition on the RAID1 volume in the two SSD.
    a=1
    b='-1cyl' # The last cylinder
    $parted /dev/sd${i} -- unit MiB mkpart lvm-ssd${n} $a $b
    $parted /dev/sd${i} set 1 raid on
done


### Creation of the RAID volumes. ###

# The system (/) partition.
mdadm --create /dev/$raid1system --level=1 --raid-devices=2 /dev/sda3 /dev/sdb3 --force --run

# The swap partition.
mdadm --create /dev/$raid1swap --level=1 --raid-devices=2 /dev/sda4 /dev/sdb4 --force --run

# The LVM partition in the harddrive.
mdadm --create /dev/$raid1hd --level=1 --raid-devices=2 /dev/sda5 /dev/sdb5 --force --run

# The SSD RAID1 volume.
mdadm --create /dev/$raid1ssd --level=1 --raid-devices=2 /dev/sdc1 /dev/sdd1 --force --run


### Creation of the volume group LVM on the HD RAID1 volume etc. ###
pvcreate -ff --yes /dev/$raid1hd
vgcreate --force --yes vg1 /dev/$raid1hd
lvcreate --name varlogmysql --size 200g vg1
lvcreate --name backups     --size 500g vg1

### Creation of the volume group LVM on the SSD RAID1 volume etc. ###
pvcreate -ff --yes /dev/$raid1ssd
vgcreate --force --yes vg2 /dev/$raid1ssd
lvcreate --name tmp         --size 30g  vg2
lvcreate --name varlibmysql --size 120g vg2


### Creation of the file systems. ###
mkfs.ext4 -F -E lazy_itable_init=0 -L system /dev/$raid1system
mkswap -L swap /dev/$raid1swap
mkfs.xfs -f -L varlogmysql /dev/mapper/vg1-varlogmysql
mkfs.xfs -f -L backups     /dev/mapper/vg1-backups
mkfs.ext4 -F -E lazy_itable_init=0 -L tmp         /dev/mapper/vg2-tmp
mkfs.ext4 -F -E lazy_itable_init=0 -L varlibmysql /dev/mapper/vg2-varlibmysql

# mkfs.vfat doesn't exist during Debian installation.
# Lowercase labels trigger a warning.
mkfs.fat -F 32 -n 'UEFI1' /dev/sda1 # partition unused but hey...
mkfs.fat -F 32 -n 'UEFI2' /dev/sdb1 # partition unused but hey...

exit 0


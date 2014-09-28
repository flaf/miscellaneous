#!/bin/sh

set -e

distrib="$1"
temp_dir=$(mktemp -d)
cd "$temp_dir"

clean () {
    rm -rf "$temp_dir"
}

trap clean EXIT


# Si on a spécifié une distribution alors on met à jour uniquement
# le noyau et le initrd.gz
if [ -n "$distrib" ]
then
    if [ "$distrib" = "trusty" ]
    then
        family="ubuntu"
        url="http://archive.ubuntu.com/ubuntu/dists/$distrib/main/installer-amd64/current/images/netboot/netboot.tar.gz"
    else
        family="debian"
        url="http://ftp.debian.org/debian/dists/$distrib/main/installer-amd64/current/images/netboot/netboot.tar.gz"
    fi
    printf "Update only linux kernel and initrd.gz of /srv/tftp/$distrib.\n"
    wget "$url"
    tar -xf netboot.tar.gz
    rm -rf "/srv/tftp/$distrib"
    mkdir -p "/srv/tftp/$distrib/$family-installer/amd64"
    mv "$temp_dir/$family-installer/amd64/initrd.gz" "/srv/tftp/$distrib/$family-installer/amd64/"
    mv "$temp_dir/$family-installer/amd64/linux" "/srv/tftp/$distrib/$family-installer/amd64/"
    chmod -R a+r "/srv/tftp/$distrib"
    cd /tmp
else
    printf "Update /srv/tftp/debian-installer.\n"
    # Actuellement le netboot de Jessie est complètement bugué.
    url="http://ftp.debian.org/debian/dists/wheezy/main/installer-amd64/current/images/netboot/netboot.tar.gz"
    wget "$url"
    tar -xf netboot.tar.gz
    rm -fr "/srv/tftp/debian-installer"
    rm -f "/srv/tftp/pxelinux.0"
    rm -f "/srv/tftp/pxelinux.cfg"
    cd "/srv/tftp"
    ln -s "debian-installer/amd64/pxelinux.0" "pxelinux.0"
    ln -s "debian-installer/amd64/pxelinux.cfg" "pxelinux.cfg"
    mv "$temp_dir/debian-installer" /srv/tftp/
    chmod -R a+r "/srv/tftp/debian-installer"
    # Il faut mettre en place notre fichier "default" issu de git.
    cd "/srv/tftp/debian-installer/amd64/pxelinux.cfg/"
    rm -f default
    ln -s "../../../miscellaneous/pxe/default" default
fi



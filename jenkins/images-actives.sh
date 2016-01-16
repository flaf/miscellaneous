###########################
### Need a Jessie image ###
###########################

TARGET_COMPONENT=xia
GIT_URL='http://gitlab.crdp.ac-versailles.fr:80/pascal.fautrero/images-actives-html5.git'
WORGING_DIR_IN_GIT='images-actives-html5/packaging'




SCRIPT=$(mktemp)
TARGET_DIR=$(mktemp -d)
HOST=$(hostname -f)

set -e

clean () {
    rm -f $SCRIPT
    rm -rf $TARGET_DIR
}

trap clean EXIT

echo "#!/bin/bash
set -e

clean () {
    chmod -R 777 $TARGET_DIR
}

trap clean EXIT

cd $TARGET_DIR

apt-get update

# Prepare environment
apt-get install --no-install-recommends --yes git openssl ca-certificates devscripts equivs lsb-release

#if [ \$(lsb_release -sc) = wheezy ]
#then
#    echo deb http://ftp.fr.debian.org/debian/ wheezy-backports main non-free contrib > /etc/apt/sources.list.d/backports.list
#    apt-get update
#fi

git clone $GIT_URL
cd $WORGING_DIR_IN_GIT

# Install build-deps
mk-build-deps --install --tool 'apt-get --yes --no-install-recommends' --remove ./debian/control

export DEBEMAIL=hudson@$HOST 
export DEBFULLNAME='Hudson CI' 
dch -i --no-auto-nmu 'Jenkins Automatic CI' --distribution stable

./debian/rules create_deb
" >$SCRIPT

pbuilder-jessie-amd64 execute --bindmounts $TARGET_DIR -- $SCRIPT
(cd "$TARGET_DIR/$WORGING_DIR_IN_GIT/.." && debsign *.changes && dput "$TARGET_COMPONENT" *.changes)



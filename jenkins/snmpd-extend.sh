TARGET_COMPONENT=shinken
GIT_URL='https://github.com/flaf/shinken-packages.git'
WORGING_DIR_IN_GIT='shinken-packages/snmpd-extend/snmpd-extend'
VERSION="$(date '+%Y%m%d%H%M')" # This is a native package so don't put `-' in the version number.




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
apt-get install --no-install-recommends --yes git openssl ca-certificates devscripts equivs

git clone $GIT_URL
cd $WORGING_DIR_IN_GIT

# Install build-deps
mk-build-deps --install --tool 'apt-get --yes --no-install-recommends' --remove ./debian/control

export DEBEMAIL=hudson@$HOST 
export DEBFULLNAME='Hudson CI' 
dch -b --newversion $VERSION --empty 'Jenkins Automatic CI' --distribution stable

./debian/rules create_deb
" >$SCRIPT

pbuilder-wheezy-amd64 execute --bindmounts $TARGET_DIR -- $SCRIPT
(cd "$TARGET_DIR/$WORGING_DIR_IN_GIT/.." && debsign *.changes && dput "$TARGET_COMPONENT" *.changes)



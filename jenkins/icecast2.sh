TARGET_COMPONENT=webradio
GIT_URL='https://github.com/flaf/miscellaneous.git'
WORGING_DIR_IN_GIT='miscellaneous/debpkg_icecast2/icecast2'




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

# Prepare environment
apt-get update
apt-get install --no-install-recommends --yes git openssl ca-certificates devscripts equivs

git clone $GIT_URL
cd $WORGING_DIR_IN_GIT

# Install build-deps
mk-build-deps --install --tool 'apt-get --yes --no-install-recommends' --remove ./debian/control

VERSION_BASE=\$(head -n1 debian/changelog | cut -d' ' -f2 | tr -d '()\n' | cut -d'+' -f1)
VERSION=\"\$VERSION_BASE+\$(date +%Y%m%d%H%M)\"
export DEBEMAIL=hudson@$HOST 
export DEBFULLNAME='Hudson CI' 
dch -b --newversion \$VERSION --empty 'Jenkins Automatic CI' --distribution stable

./debian/rules create_deb
" >$SCRIPT

pbuilder-wheezy-amd64 execute --bindmounts $TARGET_DIR -- $SCRIPT
(cd "$TARGET_DIR/$WORGING_DIR_IN_GIT/.." && debsign *.changes && dput "$TARGET_COMPONENT" *.changes)



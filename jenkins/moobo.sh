TARGET_COMPONENT=moobot
GIT_URL='https://gitlab.crdp.ac-versailles.fr/francois.lafont/moobot-package.git'
WORGING_DIR_IN_GIT='moobot-package/src'

me=$(whoami)


SCRIPT=$(mktemp)
TARGET_DIR=$(mktemp -d)
HOST=$(hostname -f)


set -e

cd $TARGET_DIR

git clone git@gitlab.crdp.ac-versailles.fr:olivier.lecam/moobot.git


tar -zcf upstream.tar.gz moobot/
rm -rf moobot/

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

upstream_version=\$(dpkg-parsechangelog | awk '/^Version/ {print \$2}' | cut -d'-' -f1)
upstream_targz="moobot_\${upstream_version}.orig.tar.gz"
upstream_version=\$upstream_version-\$(date '+%Y%m%d%H%M')

mv ../../upstream.tar.gz ../\$upstream_targz
tar --strip-components=1 -zxf "../\$upstream_targz" -C .


export DEBEMAIL=hudson@$HOST 
export DEBFULLNAME='Hudson CI' 
dch -b --newversion \$upstream_version --empty 'Jenkins Automatic CI' --distribution stable

debuild -b -us -uc --lintian-opts --pedantic -i -I && echo 'Building is OK!'
" >$SCRIPT

pbuilder-wheezy-amd64 execute --bindmounts $TARGET_DIR -- $SCRIPT
(cd "$TARGET_DIR/$WORGING_DIR_IN_GIT/.." && debsign *.changes && dput "$TARGET_COMPONENT" *.changes)



#!/bin/sh

ROOT_DIR=$(cd $(dirname "$0"); pwd)
PUPPET_DIR='/puppet/production'

rm -rf "$PUPPET_DIR/modules/icecast2"
ln -s "$ROOT_DIR/icecast2" "$PUPPET_DIR/modules/icecast2"

rm -rf "$PUPPET_DIR/modules/airtime"
ln -s "$ROOT_DIR/airtime" "$PUPPET_DIR/modules/airtime"

rm -f "$PUPPET_DIR/hieradata/fqdn/radio-puppet.athome.priv.yaml"
ln -s "$ROOT_DIR/radio-puppet.athome.priv.yaml" "$PUPPET_DIR/hieradata/fqdn/radio-puppet.athome.priv.yaml"

rm -rf "$PUPPET_DIR/modules/exim4"
ln -s "$ROOT_DIR/../shinken-puppet-lab/exim4" "$PUPPET_DIR/modules/exim4"

rm -f "$PUPPET_DIR/modules/repositories/manifests/sourcefabric.pp"
ln -s "$ROOT_DIR/sourcefabric.pp" "$PUPPET_DIR/modules/repositories/manifests/sourcefabric.pp"

echo "Don't forget to insert 'sourcefabric' entry in hieradata/default.yaml..."


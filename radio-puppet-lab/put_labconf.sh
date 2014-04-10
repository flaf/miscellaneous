#!/bin/sh

ROOT_DIR=$(cd $(dirname "$0"); pwd)
PUPPET_DIR='/puppet/production'

rm -f "$PUPPET_DIR/modules/icecast2"
ln -s "$ROOT_DIR/icecast2" "$PUPPET_DIR/modules/icecast2"

rm -f "$PUPPET_DIR/hieradata/fqdn/radio-puppet.athome.priv.yaml"
ln -s "$ROOT_DIR/radio-puppet.athome.priv.yaml" "$PUPPET_DIR/hieradata/fqdn/radio-puppet.athome.priv.yaml"



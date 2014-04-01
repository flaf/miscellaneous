#!/bin/sh

ROOT_DIR=$(cd $(dirname "$0"); pwd)
PUPPET_DIR='/puppet/production'


rm -fr "$PUPPET_DIR/modules/icecast2"
cp -ar "$ROOT_DIR/icecast2" "$PUPPET_DIR/modules/"

rm -f "$PUPPET_DIR/hieradata/fqdn/radio-puppet.athome.priv.yaml"
cp -a "$ROOT_DIR/radio-puppet.athome.priv.yaml" "$PUPPET_DIR/hieradata/fqdn/radio-puppet.athome.priv.yaml"



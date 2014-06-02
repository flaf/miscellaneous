# Installation de puppetmaster dernière version.
wget http://apt.puppetlabs.com/puppetlabs-release-wheezy.deb
dpkg -i puppetlabs-release-wheezy.deb
apt-get update
apt-get install puppetmaster

# Création du fichier pour les extdata.
mkdir /etc/puppet/extdata/
touch /etc/puppet/extdata/common.csv
chown root:root /etc/puppet/extdata/common.csv
chmod 600 /etc/puppet/extdata/common.csv
hostname | md5sum | cut -d' ' -f1 > /etc/puppet/extdata/common.csv

# Installation de puppetdeb pour avoir
# les ressources exportées.
puppet resource package puppetdb ensure=latest
puppet resource service puppetdb ensure=running enable=true
puppet resource package puppetdb-terminus ensure=latest

fqdn=$(hostname -f)

cat /etc/puppet/puppetdb.conf >/etc/puppet/puppetdb.conf <<EOF
[main]
server = $fqdn
port = 8081

EOF


cat >/etc/puppet/puppet.conf <<EOF
[main]
logdir=/var/log/puppet
vardir=/var/lib/puppet
ssldir=/var/lib/puppet/ssl
rundir=/var/run/puppet
factpath=\$vardir/lib/facter

# path of the environment directory.
confdir = /etc/puppet
environmentpath = \$confdir/environments


[master]
# These are needed when the puppetmaster is run by passenger
# and can safely be removed if webrick is used.
ssl_client_header = SSL_CLIENT_S_DN
ssl_client_verify_header = SSL_CLIENT_VERIFY

# For the puppetdb installation.
storeconfigs = true
storeconfigs_backend = puppetdb

# For the ENC script.
node_terminus=exec
external_nodes=/etc/puppet/enc

EOF


cat >/etc/puppet/hiera.yaml <<EOF
---
:backends:
  - yaml

:hierarchy:
  - "%{environment}/hieradata/%{domain}/%{clientcert}"
  - "%{environment}/hieradata/%{domain}"
  - "%{environment}/hieradata/default"

:yaml:
  :datadir: "/etc/puppet/environments"

EOF

cat >/etc/puppet/enc <<EOF
#!/bin/sh

echo "---
parameters:
  environment: 'production'
  admin: 'Francois Lafont'
"

EOF

chmod a+x /etc/puppet/enc

# Création du répertoire d'environnement.
# En fait, il faudra plutôt créer des symlinks
# qui pointent vers un dépôt git.
# Attention de ne pas mettre ce dépôt dans /root
# comme j'ai déjà pu faire car les droits sur ce
# répertoire font que ça ne marche pas (et on n'a
# pas le moindre message d'erreur éclairant sur les
# causes du problème).
mkdir -p /etc/puppet/environments/production/{hieradata,manifests,modules}

# D'après notre conf hiera, il faudra que l'on définisse
# dans /etc/puppet/environments/production/hieradata :
#       - un fichier default.yaml
#       - un fichier athome.priv.yaml etc. (un par domaine)
#       - des fichiers athome.priv/node.athome.priv.yaml etc. (un par hôte)

cat >/etc/puppet/environments/production/manifests/site.pp <<EOF
hiera_include('classes')

EOF


# Installation de la puppet stdlib.
puppet module install puppetlabs-stdlib




# TODO

* Write the README file.
* Make a schema (with puppetserver, puppetdb and postresql).




# Module description

This module allows to install a Puppet4 server.




# Quick start

```sh
apt-get install lsb-release # <= should be already installed.

KEY='47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30'
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$KEY"
COLLECTION='PC1'
distrib=$(lsb_release -sc)
collection=$(echo $COLLECTION | tr '[:upper:]' '[:lower:]')

echo "# Puppetlabs $COLLECTION $distrib Repository.
deb http://apt.puppetlabs.com $distrib $COLLECTION
#deb-src http://apt.puppetlabs.com $distrib $COLLECTION
" > /etc/apt/sources.list.d/puppetlabs-$collection.list

# Force the version number as below.
apt-get update && apt-get install puppet-agent=1.2.4-*

# For a 'autonomous' puppetserver.
/opt/puppetlabs/bin/puppet agent --test --server=$server --ssldir=/etc/puppetlabs/puppet/sslagent

# For a 'client' puppetserver.
/opt/puppetlabs/bin/puppet agent --test --server=$server
```


# A security point

The propagation of the CRL (Certificate Revocation List)
of the CA is an important point:

* puppetserver uses a CRL and must be restarted when the CRL
is updated. Typically, after a simple `puppet node clean $fqdn`,
the client is able to run puppet until the puppertserver has
restarted.

* Idem for puppetdb.



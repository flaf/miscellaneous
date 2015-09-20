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

apt-get update && apt-get install puppet-agent=1.2.4-*

/opt/puppetlabs/bin/puppet agent --test --server=$server --ssldir=/etc/puppetlabs/puppet/sslagent
```




# TODO

* Write the README file.



TODO: Please, make a real README file...


# Module description

Module to manage a HTTP proxy.


# How to retrieve the content of PGP public key

```sh
ID='6F6B15509CF8E59E6E469F327F438280EF8D349F'
dir=$(mktemp -d)
gpg --keyserver hkp://keyserver.ubuntu.com:80 --no-default-keyring --keyring "$dir/f1" --recv-keys "0x${ID}"

# Print the key on STDOUT.
gpg --armor --no-default-keyring --keyring "$dir/f1" --export "0x${ID}"

# Put the key in a file.
gpg --output pubkey.gpg --armor --no-default-keyring --keyring "$dir/f1" --export "0x${ID}"

# Cleaning.
rm -r "$dir"
```


# Usage

Here is an example below. First some Hiera data:

```yaml
httpproxy::params::squidguard_conf:
  src:
    users_src:
      ip: ['192.168.84.0/24', '192.168.85.0/24']
    deploy_src:
      ip: ['192.168.20.10', '192.168.20.11']
  dest:
    blacklisted_users:
      domainlist: 'blacklisted_users/domainlist'
    allowed_deploy:
      domainlist:
        - 'rubygems.org'
        - 'github.com'
        - 'archive.ubuntu.com'
        - 'ftp.debian.org'
  acl:
    admin_src:
      pass: 'all'
    deploy_src:
      pass: ['allowed_deploy', 'none']
    users_src:
      pass: ['!blacklisted_users', 'all']
    default:
      pass: 'none'
httpproxy::params::pgp_pubkeys:
  - name: 'puppet'
    id: '0x6F6B15509CF8E59E6E469F327F438280EF8D349F'
    content: '%{alias("_puppet_pubkey_")}'
  - name: 'ceph'
    id: '0x08B73419AC32B4E966C1A330E84AC2C0460F3994'
    content: '%{alias("_ceph_pubkey_")}'

# The content of the Puppet and Ceph PGP keys.
_puppet_pubkey_: |
  -----BEGIN PGP PUBLIC KEY BLOCK-----
  Version: GnuPG v1

  mQINBFe2Iz4BEADqbv/nWmR26bsivTDOLqrfBEvRu9kSfDMzYh9Bmik1A8Z036Eg
  h5+TZD8Rrd5TErLQ6eZFmQXk9yKFoa9/C4aBjmsL/u0yeMmVb7/66i+x3eAYGLzV
  # ...
  k2vFiMwcHdLpQ1IH8ORVRgPPsiBnBOJ/kIiXG2SxPUTjjEGOVgeA=/Tod
  -----END PGP PUBLIC KEY BLOCK-----

_ceph_pubkey_: |
  -----BEGIN PGP PUBLIC KEY BLOCK-----
  Version: GnuPG v1

  mQINBFX4hgkBEADLqn6O+UFp+ZuwccNldwvh5PzEwKUPlXKPLjQfXlQRig1flpCH
  # ...
  k2vFiMwcHdLpQ1IH8ORVRgPPsiBnBOJ/kIiXG2SxPUTjjEGOVgeA=/Tod
  -----END PGP PUBLIC KEY BLOCK-----
```

And then the Puppet code:

```puppet
# It is assumed that the variables $pgp_pubkeys and
# $squidguard_conf have the values in the Hiera code above.

class { '::httpproxy::params':
  enable_apt_cacher_ng   => true,
  apt_cacher_ng_adminpwd => 'ABCD1234',
  apt_cacher_ng_port     => 3142,
  #
  enable_keyserver       => true,
  keyserver_fqdn         => $::facts['networking']['fqdn'],
  pgp_pubkeys            => $pgp_pubkeys,
  #
  enable_puppetforgeapi  => true,
  puppetforgeapi_fqdn    => "puppetforgeapi.${domain}",
  #
  enable_squidguard      => true,
  squid_allowed_networks => ['192.168.0.0/16', '172.16.0.0/16'],
  squid_port             => 3128,
  squidguard_conf        => $squidguard_conf,
  squidguard_admin_email => "admin@${domain}",
}

include '::httpproxy'
```

Here is the SquidGuard configuration defined in
`/etc/squidguard/squidGuard.conf` by this example
(where it is assumed that 172.16.5.1 is the IP
address of the server):

```cfg
dbhome /var/lib/squidguard/db
logdir /var/log/squidguard

src users_src {
    ip 192.168.84.0/24 192.168.85.0/24
}

src deploy_src {
    ip 192.168.20.10 192.168.20.11
}

# This list is not managed by Puppet because the list is not
# given explicitly in the Hiera configuration.
dest blacklisted_users {
    domainlist blacklisted_users/domainlist
}

# This list is managed by Puppet because the list is given
# explicitly in the Hiera configuration.
dest allowed_deploy {
    domainlist allowed_deploy/domainlist
}

# Understand the "pass" instruction.
#
#   - "!foo" means "list foo not allowed".
#   - "foo" means "list foo allowed".
#   - "pass X Y none"  => nothing is allowed except X and Y.
#   - "pass !X !Y all" => all is allowed except X and Y.
#
acl {
    admin_src {
        pass all
    }
    deploy_src {
        pass allowed_deploy none
    }
    users_src {
        pass !blacklisted_users all
    }
    default {
        pass none
        redirect http://172.16.5.1/forbidden.html
    }
}
```


# Parameters

The boolean `enable_apt_cacher_ng` allows to disable/enable
the daemon apt-cacher-ng (APT proxy). Its default value is
`true`

The string `apt_cacher_ng_adminpwd` allows to define the
admin password of apt-cache-ng. There is no default value
for this parameter and you have to provide a value.

The integer `apt_cacher_ng_port` allows to define the
listening number of the daemon apt-cacher-ng. Its defaults
value is 3142.

The boolean `enable_keyserver` allows to disable/enable the
keyserver server. Its default value is `true`.

The string `keyserver_fqdn` allows to set the server name
of the vhost which provides the keyserver service which is
a basic HTTP server. To retrieve a PGP key installed on the
keyserver, you can laucnhed:

```sh
# Where "keyserver.domain.tld" is the value of the puppet
# parameter `keyserver_fqdn`
ID='6F6B15509CF8E59E6E469F327F438280EF8D349F'
gpg --keyserver hkp://keyserver.domain.tld:80 --recv-keys "0x${ID}"
```

The structure `pgp_pubkeys` provides the PGP keys offered by
the keyserver service. This parameter has the structure of
the example above. The default value of this parameter is
`[]` (ie no PGP key provided by default).




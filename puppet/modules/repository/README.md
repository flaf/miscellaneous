# Module description

This module configures APT repositories. This module
consists of several public classes and user-defined
resources.




# The class `repository::aptconf`

This class allows to manage the APT global settings.


## Usage

Here is an example:

```puppet
class { '::repository::aptconf::params':
  apt_proxy          => 'http://httpproxy.domain.tld:3142',
  install_recommends => false,
  install_suggests   => false,
  distrib_url        => 'http://ftp.fr.debian.org/debian/',
  src                => false,
  backports          => false,
}

include '::repository::aptconf:'
```


## Parameters

The `apt_proxy` parameter allows to set the APT option
`Acquire::http::Proxy`. Its default value is `undef`, ie no
APT proxy is set.

The `install_recommends` is a boolean to set the APT option
`APT::Install-Recommends`. Its default value is `false`.

The `install_suggests` is a boolean to set the APT option
`APT::Install-Suggests`. Its default value is `false`.

The `distrib_url` parameter is the URL used to reach the
official APT repositories. Its default value is:

* `'http://ftp.fr.debian.org/debian/'` for Debian distributions.
* `'http://fr.archive.ubuntu.com/ubuntu'` for Ubuntu distributions.

The `src` parameter is a boolean. If `true` then `deb-src`
lines will be added for the official APT repositories, if
`false` no `deb-src` lines. The default value is `false`.




# `repository::aptkey::params` and `repository::aptkey`

The class `repository::aptkey::params` and the user-defined
resource `repository::aptkey` allow to manage APT PGP keys.


## Usage

Here is an example:

```puppet
# To set the default settings of the user-defined resources
# "repository::aptkey".
class { '::repository::aptkey::params':
  http_proxy => 'http://httpproxy.domain.tld:3128',
  keyserver  => 'hkp://keyserver.ubuntu.com:80',
}

# This APT key will be downloaded via the default
# configuration set in "::repository::aptkey::params", ie
# via the keyserver and the HTTP proxy set above.
::repository::aptkey { 'puppetlabs':
  id => '6F6B 1550 9CF8 E59E 6E46  9F32 7F43 8280 EF8D 349F',
}

# This APT key will be downloaded via a simple wget to the
# source parameter and the HTTP proxy set above in the
# default configuration in "::repository::aptkey::params"
# will be used by the wget command.
repository::aptkey { 'shinken':
  id     => '0x741FA112F3B2D515A58543F83DE39DE978BB3659',
  source => 'http://shinken.domain.tld/pubkey.gpg',
}
```


## Parameters of the class `repository::aptkey::params`

The parameter `http_proxy` set a HTTP used by default by a
resource `repository::aptkey` to retrieve the APT key. If
you set this parameter, all your `repository::aptkey`
resources will use this HTTP proxy to retrieve the APT keys,
without exception. The default value of this parameter
is `undef` ie no HTTP proxy.

The parameter `keyserver` set the key server used by default
by a resource `repository::aptkey` to retrieve its APT key.
If you set this parameter, all your `repository::aptkey`
resources will use this key server to retrieve the APT keys
via the command:

```sh
# If a HTTP proxy is set, the environment variable http_proxy is set before.
apt-key adv --keyserver "$keyserver" --recv-keys "$id"
```

without exception. If this parameter is undefined, it
depends on the parameters of each resource
`repository::aptkey` (see below). The default value of this
parameter is `undef`.


## Paramters of the user-defined resource `repository::aptkey`

The `id` parameter is the fingerprint ID of the APT key.
This parameter has no default value and is mandatory. The
string value can have spaces or not, and can have the `0x`
prefix or not.

The `keyserver` parameter is the key server used to retrieve
the APT key. The default value of this parameter is `undef`.
Now, here is the `keyserver` policy:

1. If `repository::aptkey::keysever` (from the user-defined resource)
   is not `undef`, this key server is used to download the APT key.
2. If `repository::aptkey::keysever` is `undef`:
    * If `repository::aptkey::params::keysever` (from the class)
      is not `undef`, this key server is used to download the APT
      key.
    * If `repository::aptkey::params::keysever` is `undef`, then:
        * If not undefined, the `source` parameter will be used to
          download the APT key via a `wget` command.
        * If the `source` parameter is undefined, the key server
          `hkp://keyserver.ubuntu.com:80` will be used.

The `source` parameter is the URL to download the APT key
via `wget`. The default value is `undef`. As you can see in
the policy described above, this parameter can be ignored if a
key server is defined (via the parameter
`repository::aptkey::params::keysever` or the parameter
`repository::aptkey::keysever`).

The `http_proxy` is the HTTP proxy used to retrieve the APT
key (via a key server or via a `wget`).  The default value
of this parameter is `undef`. The `http_proxy` policy is:

1. If `repository::aptkey::http_proxy` (from the user-defined resource)
   is not `undef`, this HTTP proxy will be used to retrieve the APT key.
2. If `repository::aptkey::http_proxy` is `undef`:
    * If `repository::aptkey::params::http_proxy` (from the class)
      is not `undef`, this HTTP proxy will be used to retrieve the APT
      key.
    * If `repository::aptkey::params::http_proxy` is `undef`, then
      no HTTP proxy will be used to retrieve the APT key.




# The user-defined resource `repository::sourceslist`


## Usage

Here is an example:

```puppet
class { '::repository::aptkey::params':
  http_proxy => 'http://httpproxy.domain.tld:3128',
  keyserver  => 'hkp://keyserver.ubuntu.com:80',
}

::repository::aptkey { 'puppetlabs':
  id => '6F6B 1550 9CF8 E59E 6E46  9F32 7F43 8280 EF8D 349F',
}

repository::sourceslist { "puppetlabs-pc1":
  # "id" is useless because the default value of this
  # attribute is the title of the resource.
  id         => 'puppetlabs-pc1',
  comment    => 'Puppetlabs PC1 trusty Repository.',
  location   => 'http://apt.puppetlabs.com',
  release    => 'trusty',
  components => [ 'PC1' ],
  src        => false,
  apt_update => true,
  require    => Repository::Aptkey['puppetlabs'],
}
```


## Parameters

The `id` parameter allow to define the name of the
source.list file. The full path of this file will be
`/etc/apt/sources.list.d/${id}.list`. The default value of
this parameter is the title of the resource.

The `comment` parameter is just a comment put in the file
`/etc/apt/sources.list.d/${id}.list`. This parameter has no
default value.

The syntax of the line put in the file
`/etc/apt/sources.list.d/${id}.list` will be :

```puppet
deb ${location} ${release} ${components.join(' ')}
```

The parameters `location`, `release` and `components`
have no default value.

The parameter `src` is a boolean to add the line `deb-src`
is set to `true`. Its default value is `false`.

The parameter `apt_update` is a boolean. If set to `true`,
it triggers the command `apt-get update` if the resource is
changed. The default value of this parameter is `true`.




# The user-defined resource `repository::pinning`


## Usage

Here is an example:

```puppet
repository::pinning { 'puppet-agent':
  # Useless because the default value of this attribute is
  # the title of the resource.
  id          => 'puppet-agent',
  explanation => 'To ensure the version of the puppet-agent package.',
  packages    => 'puppet-agent',
  version     => '1.9.3-*',
  priority    => 990,
}
```


## Parameters

The `id` parameter allow to define the name of the pinning
file. The full path of this file will be
`/etc/apt/preferences.d/${id}.pref`. The default value of
this parameter is the title of the resource.

Here is the form of the pinning file:

```puppet
Explanation: $explanation
Package: $packages
Pin: version $version
Pin-Priority: $priority
```

* The parameter `explanation` has no default value.
* The parameter `packages` has no default value.
* The parameter `version` has no default value.
* The default value of `priority` is `500`.




# The `::repository::puppet` class

## Usage

Here is an example:

```puppet
class { '::repository::puppet::params':
  url                    => 'http://apt.puppetlabs.com',
  src                    => false,
  apt_key_fingerprint    => '6F6B 1550 9CF8 E59E 6E46 9F32 7F43 8280 EF8D 349F',
  collection             => 'PC1',
  pinning_agent_version  => '1.3.0-*', # Don't forget the joker.
}

include '::repository::puppet'
```

## Parameters

The default values of the parameters `url`, `src` and
`apt_key_fingerprint` are the values of the example above.

The `collection` parameter gives the name of the collection
which will be used. The `pinning_agent_version` parameter
gives the version of the `puppet-agent` package which will
be pinned in the APT configuration. For the
`pinning_agent_version` parameter, the special string value
`'none'` means "no pinning". For these 2 parameters the
default value is `undef` and you have to provide a value
explicitly. For instance in hiera with something like that:

```yaml
repository::puppet::params::collection: 'PC1'
repository::puppet::params::pinning_agent_version: '1.3.0-*'
```




# The `::repository::puppetserver` class

## Usage

Here is an example:

```puppet
# The class repository::puppetserver doesn't manage the
# Puppetlabs repository in the sources.list.d directory.
# This is the goal of the repository::puppet class.
include '::repository::puppet'

# The class repository::puppetserver only manages pinnings
# of some packages used by a Puppet server.
class { '::repository::puppetserver::params':
  pinning_puppetserver_version     => '2.6.0-*', # Don't forget the joker.
  pinning_puppetdb_version         => '4.2.2-*', # Don't forget the joker.
  pinning_puppetdb_termini_version => '4.2.2-*', # Don't forget the joker.
}

include '::repository::puppetserver'
```

## Parameters

**Warning :** this class only manages pinnings of some
packages used by a Puppet server. It doesn't manage the
Puppetlabs repository in the `sources.list.d` directory
which is managed by the `repository::puppet` class. So,
normally, for a Puppet server, you should apply the class
`repository::puppet` **and** the class
`repository::puppetserver` together.

The parameters `pinning_puppetserver_version`,
`pinning_puppetdb_version` and
`pinning_puppetdb_termini_version` pin the version of these
packages respectively: `puppetserver`, `puppetdb` and
`puppetdb-termini`. The special string value `'none'` means
"no pinning". For these 3 parameters the default value is
`undef` and you have to provide a value explicitly.




# The `repository::postgresql` class

## Usage

Here is an example:

```puppet
class { '::repository::postgresql::params':
  url                 => 'http://apt.postgresql.org/pub/repos/apt/',
  src                 => false,
  apt_key_fingerprint => 'B97B 0AFC AA1A 47F0 44F2 44A0 7FCC 7D46 ACCC 4CF8'
}

include '::repository::postgresql'
```

## Parameters and default values

The default values of the parameters are exactly
the values of the call above.




# The `repository::ceph` class

## Usage

Here is an example:

```puppet
class { '::repository::ceph::params':
  url                 => 'http://download.ceph.com',
  src                 => false,
  apt_key_fingerprint => '08B7 3419 AC32 B4E9 66C1  A330 E84A C2C0 460F 3994',
  codename            => 'infernalis',
  pinning_version     => '9.2.0-*',
}

include '::repository::ceph'
```

## Parameters and default values

Only `url`, `src` and `apt_key_fingerprint` parameters have
default values which are the value in the example above. The
`codename` and `pinning_version` have not relevant default
value (it's `undef`) and you must provide relevant values
explicitly. For the `pinning_version` parameter, the string
value `'none'` is special and means "no pinning".

Remark: the complete url used by APT is
`"${url}/debian-${codename}"` which is the nomenclature used
by the official Ceph repository.




# The `repository::gitlab` class

## Usage

Here is an example:

```puppet
$distro_id = $::facts["os"]["distro"]["id"].downcase()

class { '::repository::gitlab::params':
  url                 => "http://packages.gitlab.com/gitlab/gitlab-ce/${distro_id}/",
  src                 => false,
  apt_key_fingerprint => '1A4C 919D B987 D435 9396 38B9 1421 9A96 E15E 78F4',
  pinning_version     => '8.10.8-*',
}

include '::repository::gitlab'
```

## Parameters and default values

Only `url`, `src` and `apt_key_fingerprint` parameters have
default values which are the values used above. The
`pinning_version` has not relevant default value (it's
`undef`) and you must provide a relevant value explicitly.
The string value `'none'` is special and means "no pinning".




# The `repository::docker` class

## Usage

Here is an example:

```puppet
class { '::repository::docker::params':
  url                 => 'http://apt.dockerproject.org/repo/dists',
  src                 => false,
  apt_key_fingerprint => '5811 8E89 F3A9 1289 7C07 0ADB F762 2157 2C52 609D',
  pinning_version     => '1.10.0-*',
}

include '::repository::docker'
```

## Parameters and default values

Except for `pinning_version`, the default values of the
parameters are exactly the values of the call above. The
parameter `pinning_version` provides a pinning for the
package `docker-engine`. Its default value is `undef` and
you must provide a value explicitly. The special value
`'none'` means "no pinning".




# The `repository::proxmox` class

## Usage

Here is an example:

```puppet
class { '::repository::proxmox::params':
  url => 'https://enterprise.proxmox.com/debian',
}

include '::repository::proxmox'
```

## Parameters and default values

The default values of the parameters are exactly
the values of the call above.




# The `repository::hp_proliant` class


## Usage

Here is an example:

```puppet
class { '::repository::hp_proliant::params':
  url                 => 'http://downloads.linux.hpe.com/SDR/repo/mcp',
  apt_key_fingerprint => '5744 6EFD E098 E5C9 34B6 9C7D C208 ADDE 26C2 B797',
}

include '::repository::hp_proliant'
```


## Parameters

The default values of the parameters `url` and
`apt_key_fingerprint` are the same values as in the example
above.




# The homemade local repositories

This section concerns the classes:

- `repository::jrds`
- `repository::mco`
- `repository::moobot`
- `repository::php`
- `repository::raid`
- `repository::shinken`

which work with exactly the same way.

## Usage

Here is an example with `shinken`. It's the same thing with
the other classes above:

```puppet
class { '::repository::shinken::params':
  url                 => 'http://repository.crdp.ac-versailles.fr',
  key_url             => 'http://repository.crdp.ac-versailles.fr/crdp.gpg',
  apt_key_fingerprint => '741F A112 F3B2 D515 A885 93F8 3DE3 9DE9 78BB 3659',
}

include '::repository::shinken'
```

## Parameters and default values

The default values of the parameters are exactly
the values of the call above.





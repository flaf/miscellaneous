# Module description

This module configures APT repositories. This module
consists of several public classes.

**Warning:** the default stage of the public classes of this
module is `'repository'`, not `'main'`.




# The `repository::distrib` class

## Usage

Here is an example:

```puppet
class { '::repository::distrib::params':
  url                => 'http://ftp.fr.debian.org/debian/',
  src                => false,
  install_recommends => false,
  backports          => false,
}

include '::repository::distrib'
```

## Parameters

The `url` parameter is the url of the repository
which will be used. Its default value is:

* `http://ftp.fr.debian.org/debian/` for a Debian Operating system;
* `http://fr.archive.ubuntu.com/ubuntu` for a Ubuntu Operating system.

The `src` parameter is a boolean. If `true` then `deb-src`
lines will be added, if `false` no `deb-src` lines. The
default value is `false`.

The `install_recommends` is a boolean to tell if Puppet
sets the parameter `APT::Install-Recommends` to `true`
or `false`. The default value of this parameter is `false`.

The `backports` is a boolean to tell if Puppet
adds the backports repository for Debian. The default value
of this parameter is `false`. If set to `true` for a node which
is not a Debian operating system (for instance for a Ubuntu node),
it raises an error.

**Warning:** with this class, the file `/etc/apt/sources.list`,
the directory `/etc/apt/sources.list.d/` and the directory
`/etc/apt/preferences.d/` will be completely managed by Puppet.
For instance, to add a specific repository you have to do it
via Puppet.




# The `::repository::puppet` class

## Usage

Here is an example:

```puppet
class { '::repository::puppet::params':
  url                    => 'http://apt.puppetlabs.com',
  src                    => false,
  collection             => 'PC1',
  pinning_agent_version  => '1.3.0-*', # Don't forget the joker.
  pinning_server_version => '2.2.0-*', # Don't forget the joker.
}

include '::repository::puppet'
```

## Parameters

The `url` parameter is the url of the APT repository.
Its default value is `http://apt.puppetlabs.com`.

The `src` parameter is a boolean to tell if you
want to include the `deb-src` line or not in the
`sources.list.d/`. Its default value is `false`.

The `collection` gives the name of the collection
which will be used. The `pinning_agent_version` and
`pinning_server_version` parameters give the version
of the `puppet-agent` package and the `puppetserver` package
which will be pinned in the APT configuration. For the
`pinning_agent_version` and
`pinning_server_version` parameters, the special
string value `'none'` means "no pinning". These 3 parameters
the default value is `undef` and you have to provide a value
explicitly. For instance in hiera with something like that:

```yaml
repository::puppet::params::collection: 'PC1'
repository::puppet::params::pinning_agent_version: '1.3.0-*'
repository::puppet::params::pinning_server_version: '2.2.0-*'
```




# The `repository::postgresql` class

## Usage

Here is an example:

```puppet
class { '::repository::postgresql::params':
  url => 'http://apt.postgresql.org/pub/repos/apt/',
  src => false,
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
  url             => 'http://ceph.com',
  codename        => 'infernalis',
  pinning_version => '9.2.0-*',
  src             => false,
}

include '::repository::ceph'
```

## Parameters and default values

Only `url` and `src` parameters have a default
value which are respectively `http://ceph.com` and `false`.
The `codename` and `pinning_version` have not
relevant default value (it's `undef`) and you must provide
relevant values explicitly. For the `pinning_version`
parameter, the string value `'none'` is special and means
"no pinning".

Remark: the complete url used by APT is
`"${url}/debian-${codename}"` which is the nomenclature used
by the official Ceph repository.




# The `repository::docker` class

## Usage

Here is an example:

```puppet
class { '::repository::docker::params':
  url             => 'http://apt.dockerproject.org/repo/dists',
  src             => false,
  pinning_version => '1.10.0-*',
}

include '::repository::docker'
```

## Parameters and default values

Except for `pinning_version`, the default values of
the parameters are exactly the values of the call above. The
parameter `pinning_version` provides a pinning for
the package `docker-engine`. Its default value is `undef`
and you must provide a value explicitly. The special value
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




# The homemade local repositories

This section concerns the classes:

- `repository::shinken`,
- `repository::raid`
- `repository::mco`
- `repository::moobot`,
- `repository::jrds`
- `repository::php`

which work with exactly the same way.

## Usage

Here is an example with `shinken`. It's the same thing with
the other classes above:

```puppet
class { '::repository::shinken::params':
  url         => 'http://repository.crdp.ac-versailles.fr',
  key_url     => 'http://repository.crdp.ac-versailles.fr/crdp.gpg',
  fingerprint => '741FA112F3B2D515A88593F83DE39DE978BB3659',
}

include '::repository::shinken'
```

## Parameters and default values

The default values of the parameters are exactly
the values of the call above.





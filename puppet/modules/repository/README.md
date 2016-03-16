# Module description

This module configures APT repositories. This module
consists of several public classes.

Remark: this module implements the "params" design pattern.


# The `repository::distrib` class

## Usage

Here is an example:

```puppet
class { '::repository::params':
  distrib_url                => 'http://ftp.fr.debian.org/debian/',
  distrib_src                => false,
  distrib_install_recommends => false,
}

include '::repository::distrib'
```

## Parameters and default values

The `distrib_url` parameter is the url of the repository which will be used.
Its default value is:

* `http://ftp.fr.debian.org/debian/` for a Debian Operating system;
* `http://fr.archive.ubuntu.com/ubuntu` for a Ubuntu Operating system.

The `distrib_src` parameter is a boolean. If `true` then `deb-src`
lines will be added, if `false` no `deb-src` lines. The
default value is `false`.

The `distrib_install_recommends` is a boolean to tell if Puppet
sets the parameter `APT::Install-Recommends` to `true`
or `false`. The default value of this parameter is `false`.

**Warning:** with this class, the file `/etc/apt/sources.list`,
the directory `/etc/apt/sources.list.d/` and the directory
`/etc/apt/preferences.d/` will be completely managed by Puppet.
For instance, to add a specific repository you have to do it
via Puppet.


# The `::repository::puppet` class

## Usage

Here is an example:

```puppet
class { '::repository::params':
  puppet_url                    => 'http://apt.puppetlabs.com',
  puppet_src                    => false,
  puppet_collection             => 'PC1',
  puppet_pinning_agent_version  => '1.3.0-*', # Don't forget the joker.
  puppet_pinning_server_version => '2.2.0-*', # Don't forget the joker.
}

include '::repository::puppet'
```

## Data binding

The `puppet_url` parameter is the url of the APT repository.
Its default value is `http://apt.puppetlabs.com`.

The `puppet_src` parameter is a boolean to tell if you
want to include the `deb-src` line or not in the
`sources.list.d/`. Its default value is `false`.

The `puppet_collection` gives the name of the collection
which will be used. The `puppet_pinning_agent_version` and
`puppet_pinning_server_version` parameters give the version
of the `puppet-agent` package and the `puppetserver` package
which will be pinned in the APT configuration. For the
`puppet_pinning_agent_version` and
`puppet_pinning_server_version` parameters, the special
string value `'none'` means "no pinning". These 3 parameters
have not relevant default value (the string `'NOT-DEFINED'`
and you must provide values yourself. For instance in hiera
with something like that:

```yaml
repository::params::puppet_collection: 'PC1'
repository::params::puppet_pinning_agent_version: '1.3.0-*'
repository::params::puppet_pinning_server_version: '2.2.0-*'
```




# The `repository::postgresql` class

## Usage

Here is an example:

```puppet
class { '::repository::postgresql':
  postgresql_url => 'http://apt.postgresql.org/pub/repos/apt/',
  postgresql_src => false,
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
class { '::repository::params':
  ceph_url             => 'http://ceph.com',
  ceph_codename        => 'infernalis',
  ceph_pinning_version => '9.2.0-*',
  ceph_src             => false,
}

include '::repository::ceph'
```

## Parameters and default values

Only `ceph_url` and `ceph_src` parameters have a default
value which are respectively `http://ceph.com` and `false`.
The `ceph_codename` and `ceph_pinning_version` have not
relevant default value (it's the string `'NOT-DEFINED'`) and
you must provide relevant values explicitly. For the
`ceph_pinning_version` parameter, the string value `'none'`
is special and means "no pinning".

Remark: the complete url used by APT is
`"${url}/debian-${codename}"` which is the nomenclature used
by the official Ceph repository.




# The `repository::docker` class

## Usage

Here is an example:

```puppet
class { '::repository::params':
  docker_url => 'http://apt.dockerproject.org/repo/dists',
  docker_src => false,
}

include '::repository::docker'
```

## Parameters and default values

The default values of the parameters are exactly
the values of the call above.




# The `repository::proxmox` class

## Usage

Here is an example:

```puppet
class { '::repository::params':
  proxmox_url => 'https://enterprise.proxmox.com/debian',
}

include '::repository::proxmox'
```

## Parameters and default values

The default values of the parameters are exactly
the values of the call above.




# The homemade local repository

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
class { '::repository::params':
  shinken_url         => 'http://repository.crdp.ac-versailles.fr',
  shinken_key_url     => 'http://repository.crdp.ac-versailles.fr/crdp.gpg',
  shinken_fingerprint => '741FA112F3B2D515A88593F83DE39DE978BB3659',
}

include '::repository::shinken'
```

## Parameters and default values

The default values of the parameters are exactly
the values of the call above.




# TODO

* Add pinning support for the docker repository.



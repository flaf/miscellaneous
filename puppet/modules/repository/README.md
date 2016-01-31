# Module description

This module configures APT repositories. This module
consists of several public classes.



# The `repository::distrib` class

## Usage

Here is an example:

```puppet
class { '::repository::distrib':
  url                => 'http://ftp.fr.debian.org/debian/',
  src                => false,
  install_recommends => false,
}
```

## Parameters and default values

The `url` parameter is the url of the repository which will be used.
Its default value is:

* `http://ftp.fr.debian.org/debian/` for a Debian Operating system;
* `http://fr.archive.ubuntu.com/ubuntu` for a Ubuntu Operating system.

The `src` parameter is a boolean. If `true` then `deb-src`
lines will be added, if `false` no `deb-src` lines. The
default value is `false`.

The `install_recommends` is a boolean to tell if Puppet
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

class { '::repository::puppet':
  url                    => 'http://apt.puppetlabs.com',
  src                    => false,
  collection             => 'PC1',
  pinning_agent_version  => '1.3.0-*', # Don't forget the joker.
  pinning_server_version => '2.2.0-*', # Don't forget the joker.
}
```

## Data binding

The `url` parameter is the url of the APT repository.
Its default value is `http://apt.puppetlabs.com`.

The `src` parameter is a boolean to tell if you
want to include the `deb-src` line or not in the
`sources.list.d/`. Its default value is `false`.

The `collection` gives the name of the collection which will
be used. The `pinning_agent_version` and
`pinning_server_version` parameters give the version of the
`puppet-agent` package and the `puppetserver` package which
will be pinned in the APT configuration. For the
`pinning_agent_version` and `pinning_server_version`
parameters, the special string value `'none'` means "no
pinning". These 3 parameters have no default value and you
must provide values yourself. For instance in hiera with
something like that:

```yaml
repository::puppet::collection: 'PC1'
repository::puppet::pinning_agent_version: '1.3.0-*'
repository::puppet::pinning_server_version: '2.2.0-*'
```




# The `repository::postgresql` class

## Usage

Here is an example:

```puppet
class { '::repository::postgresql':
  url => 'http://apt.postgresql.org/pub/repos/apt/',
  src => false,
}
```

## Parameters and default values

The default values of the parameters are exactly
the values of the call above.




# The `repository::ceph` class

## Usage

Here is an example:

```puppet
class { '::repository::ceph':
  url             => 'http://ceph.com',
  codename        => 'infernalis',
  pinning_version => '9.2.0-*',
  src             => false,
}
```

## Parameters and default values

Only `url` and `src` parameters have a default value which
are respectively `http://ceph.com` and `false`. The
`codename` and `pinning_version` have no default value and
are mandatory. For the `pinning_version` parameter, the
string value `'none'` is special and means "no pinning".

Remark: The complete url used by APT is
`"${url}/debian-${codename}"` which is the nomenclature used
by the official Ceph repository.




# The `repository::docker` class

## Usage

Here is an example:

```puppet
class { '::repository::docker':
  url => 'http://apt.dockerproject.org/repo/dists',
  src => false,
}
```

## Parameters and default values

The default values of the parameters are exactly
the values of the call above.




# The `repository::moobot` class

## Usage

Here is an example:

```puppet
class { '::repository::moobot':
  url         => 'http://repository.crdp.ac-versailles.fr',
  key_url     => 'http://repository.crdp.ac-versailles.fr/crdp.gpg',
  fingerprint => '741FA112F3B2D515A88593F83DE39DE978BB3659',
}
```

## Parameters and default values

The default values of the parameters are exactly
the values of the call above.




# The `repository::shinken`, `repository::jrds` and `repository::raid` classes

## Usage

Here is an example with `shinken` (it's the same with `jrds` and `raid`):

```puppet
class { '::repository::shinken':
  url         => 'http://repository.crdp.ac-versailles.fr',
  key_url     => 'http://repository.crdp.ac-versailles.fr/crdp.gpg',
  fingerprint => '741FA112F3B2D515A88593F83DE39DE978BB3659',
}
```

## Parameters and default values

The default values of the parameters are exactly
the values of the call above.




# TODO

* Add pinning support for the docker repository.



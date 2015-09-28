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
  url                   => 'http://apt.puppetlabs.com',
  src                   => false,
  collection            => 'PC1',
  pinning_agent_version => '1.2.*', # Don't forget the joker.
}
```

## Data binding

The `url` parameter is the url of the APT repository.
Its default value is `http://apt.puppetlabs.com`.

The `src` parameter is a boolean to tell if you
want to include the `deb-src` line or not in the
`sources.list.d/`.

The `collection` and `pinning_agent_version`
parameters give the name of the collection and
the version of the `puppet-agent` package which
will be installed. For the `pinning_agent_version`
parameter, the special string value `none` means
"no pinning". To find the default values of these
2 parameters, there is a lookup of the `puppet`
entry in hiera (or in the environment). This entry
must have this form below:

```yaml
puppet:
  collection: 'PC1'
  pinning_agent_version: '1.2.*'
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
the value of the call above.





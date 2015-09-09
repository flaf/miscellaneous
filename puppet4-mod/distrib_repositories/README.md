# Module description

This module configures the official APT repositories
of the current distribution.




# Usage

Here is some examples:

```puppet
class { '::distrib_repositories':
  url                => 'http://ftp.fr.debian.org/debian/',
  src                => false,
  install_recommends => false,
}
```

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

**Warning:** with this module, the file `/etc/apt/sources.list`
and the directory `/etc/apt/sources.list.d/` will be completely
managed by Puppet. For instance, to use add a specific repository
you have to do it via Puppet.



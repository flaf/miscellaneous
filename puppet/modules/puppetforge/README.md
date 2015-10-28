# Module description

This module manages a Puppet forge server.
This module uses this very simple and functional
[software](https://github.com/unibet/puppet-forge-server).
The Puppet forge server hosts in fact two services:
- a http server which will be requested by the puppetservers to
install Puppet modules,
- a daemon which retrieves modules given in a list of git repositories.


# Usage

Here is an example:

```puppet
$modules_git_urls = [
                      'git@github.com/flaf/foo1.git',
                      'git@github.com/flaf/foo2.git',
                      'git@github.com/flaf/foo3.git',
                      'https://github.com/joe/bar.git',
                    ]

class { '::puppetforge':
  puppetforge_git_url => 'http://github.com/unibet/puppet-forge-server',
  commit_id           => '6f1b224a4e666c754876139f3643b22f3515f5e6',
  remote_forge        => 'https://forgeapi.puppetlabs.com',
  address             => '0.0.0.0',
  port                => 8080,
  modules_git_urls    => $modules_git_urls,
  pause               => 300,
}
```


# Data binding

The `puppetforge_git_url` is the url of the repository used to
installed the Puppet forge. The default value of this
parameter is `'http://github.com/unibet/puppet-forge-server'`
and you should probably never change this value.

The `commit_id` parameter is the commit ID of the
git repository used to installd the Puppet forge.
Its default value is currently `'6f1b224a4e666c754876139f3643b22f3515f5e6'`
which points to the version 1.8.0 of the software.

The `remote_forge` parameter is the url of the remote forge
used by the server. Like a DNS server, if the Puppet forge
server receives a request for a module which is not hosted
by itself, it forwards the request to this remove forge. The
default value of this parameter is
`'https://forgeapi.puppetlabs.com'` which is the official
Puppetlabs forge. Normally, you should never change this
value.

The `address` and the `port` parameters allow to set the
address used by the http Puppet forge service. The default
value of these parameters are `'0.0.0.0'` (listen to all
interfaces) for `address` and the integer `8080` for `port`.

The `modules_git_urls` parameter is an array of non-empty strings
which defines the git repositories of the modules retrieved
by the Puppet forge. The Puppet forge server will apply
these modules to the puppetservers (clients of the Puppet
forge server). Here is two conditions to release a new version
of a module :

1. The git repository of the module has a tag `T`.
2. On the commit linked to the tag `T`, the version of the
module matches with the tag value (ie `tag value T == version
of the module`),

If the conditions 1. and 2. are satisfied, then the Puppet forge
server will release the module version `T`. The Puppet forge
server can host several versions of a module. The default value
of this parameter is `[]` (an empty array), in this case the
Puppet forge server retrieves no module.

The Puppet forge retrieves new commits (via a `git pull`)
of the modules listed in `modules_git_urls` every `pause` seconds.
The default value of the `pause` parameter is 300 (seconds).

**Warning :** the daemon which retrieves modules given in the
list of git repositories runs as the `puppetforge` UniX account.
If some repositories need to be authenticated with a ssh key
(for instance), you must generate a ssh key pair **manually** for
the `puppetforge` account (`su - puppetforge`, `ssh-keygen ...` etc).


TODO:

* implement some cleaning procedures.



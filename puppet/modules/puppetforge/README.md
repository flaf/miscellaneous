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
Its default value is `'6f1b224a4e666c754876139f3643b22f3515f5e6'`
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
interfaces) and `8080` (an integer).

The `modules_git_urls` parameter is an array of non-empty strings
which defines the git repositories of the modules retrieved
by the Puppet forge. The Puppet forge server will apply
these modules to the puppetserver (clients of the Puppet
forge server). **If a git repository of a module has a tag T
and if on the commit linked to the tag T, the version of the
module matches with the tag value (T == tag value == version
of the module), the Puppet forge will release the module
version T** (the Puppet forge can host several versions of a
module). The default value of this parameter is `[]` (an
empty array), in this case the Puppet forge server retrieves
no module.

The Puppet forge retrieves new commits (via a `git pull`)
of the modules listed in `modules_git_urls` every `pause` seconds.
The default value of the `pause` parameter is 300 (seconds).




TODO:

* implement some cleaning procedures.


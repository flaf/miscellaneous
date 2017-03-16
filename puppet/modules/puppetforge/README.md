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

$sshkeypair = {
  'pubkey'  => 'XXXXXXXXX', # Just the public key without the key type and
                            # the comment.
  'privkey' => 'YYYYYYYYY', # The exact content of ~/.ssh/id_rsa file.
}

class { '::puppetforge::params':
  puppetforge_git_url => 'http://github.com/unibet/puppet-forge-server',
  http_proxy          => 'http://httproxy.domain.tld:3128',
  https_proxy         => 'http://httproxy.domain.tld:3128',
  commit_id           => '6f1b224a4e666c754876139f3643b22f3515f5e6',
  remote_forge        => 'https://forgeapi.puppetlabs.com',
  address             => '0.0.0.0',
  port                => 8080,
  modules_git_urls    => $modules_git_urls,
  pause               => 300,
  release_retention   => 5,
  puppet_bin_dir      => '/opt/puppetlabs/puppet/bin',
}

include '::puppetforge'
```


# Parameters of the class `puppetforge::params`

The `puppetforge_git_url` is the url of the repository used to
installed the Puppet forge. The default value of this
parameter is `'http://github.com/unibet/puppet-forge-server'`
and you should probably never change this value.

The `http_proxy` and `https_proxy` parameters allow to
define the environment variables `http_proxy` and
`https_proxy` if there is a HTTP(s) proxy in the network. In
this case, it's required during the `git clone` of the
`puppet-forge-server` repository and during some `gem
install`. The default value of these parameters is `undef`,
ie no HTTP(s) proxy is used.

The `commit_id` parameter is the commit ID of the
git repository used to installd the Puppet forge.
Its default value should be, as much as possible,
linked to a stable version of the software.

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
module matches with the tag value (ie `tag value T == current version
of the module in the metadata.json file`),

If the conditions 1. and 2. are satisfied, then the Puppet forge
server will release the module version `T`. The Puppet forge
server can host several versions of a module. The default value
of the parameter `modules_git_urls` is `[]` (an empty array), in
this case the Puppet forge server retrieves no module.

The Puppet forge retrieves new commits (via a `git pull`)
of the modules listed in `modules_git_urls` every `pause` seconds.
The default value of the `pause` parameter is 300 (seconds).

The `release_retention` is the maximum number of different
releases of a same module the puppetforge server must keep.
The default value of this parameter is 5.

The `puppet_bin_dir` parameter is a string which gives  the
bin directory of the puppet-agent package. This parameter
has no default value (`undef` is the default in fact)  and
should be explicitly provided by the user of this module.

The `sshkeypair` is optional. If present, this parameter must
have the exact structure in the example above. This parameter
can be useful to set the ssh key pair when authentication is
needed to clone/pull the git repositories. Be careful, **it's
necessarily a RSA key pair**. If not present, the default value
of this parameter is `undef` and no ssh key pair is managed.

**Warning:** even with the `sshkeypair` parameter, you have
to launch some manual `git clone` with the `puppetforge`
Unix account in order to accept (and put in
`~/.ssh/known_hosts`) the ssh host keys from all the "git"
hosts present in the `modules_git_urls` parameter.


TODO:

* implement the service "update-pp-module" via a push
  system (ie the host receives a message from the
  git server and so trigger an update locally.



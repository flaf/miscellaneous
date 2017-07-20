# Module description

Module to export some configurations in a server, the
collector. With the class `confkeeper::collector`, you can
install a collector (via gitolite) and with the class
`confkeeper::provider`, you can install a provider, ie a
host which will export its configuration (via etckeeper).


# The data type `Confkeeper::GitRepositories`

This data type represents a list of git repositories **in a
provider** which will be copied in the collector. It's a
hash where each key is the local path of a git directory
(the path mustn't have a trailing slash). Here is an example
of a such data type `Confkeeper::GitRepositories`:

```puppet
# Just for convenience:
$fqdn = $facts['networking']['fqdn']

$repositories = {
  '/path/foo/bar' => {
                      relapath    => "${fqdn}/path-foo-bar.git",
                      permissions => [{'rights' => 'RW+', 'target' => "root@${fqdn}"}],
                      gitignore   => [],
                     },
  '/etc'          => {
                      gitignore   => undef,
                     },
  '/usr/local'    => {
                      # Use all default values.
                     },
  '/opt'          => {
                      # exclude the directory /opt/puppetlabs/.
                      gitignore   => ['/puppetlabs/'],
                     },
}
```

For each local repository, ie for each key of the variable
`$repositories` above, the value has this structure:

```puppet
# Just for convenience:
$fqdn = $::confkeeper::provider::params::fqdn

# Just for convenience.
$collector_address = ... # retrieved by the provider via a puppetdb query.

# Here is an example of structure with comments:
{
  # To define the remote origin URL of the git repository.
  # With this value, the URL will be:
  #
  #     git@${collector_address}:aaa/foo.git
  #
  # This key is optional and, for the directory
  # "/path/foo/bar" (for instance), its default value is:
  #
  #     ${fqdn}/path-foo-bar.git.
  #
  relapath    => 'aaa/foo.git',

  # To define the gitolite permissions of the git
  # repository. This key is optional and its default value
  # is the value below where "root@${fqdn}" is a gitolite
  # user which related to a ssh key pair automatically
  # created by Puppet in the provider. The public ssh key
  # is automatically exported in the collector server.
  permissions => [
                  {'rights' => 'RW+', 'target' => "root@${fqdn}"},
                 ],

  # To define the content of the .gitignore in the git
  # repository. It's an array where an element is a line in
  # the .gitignore file. The key is optional and its default
  # value is `[]` (an empty array) to have an empty
  # .gitignore. The special value `undef` is possible: in
  # this case, a default .gitignore file is created by
  # etckeeper. This default .gitignore is relevant for the
  # repository /etc but probably not for another directory.
  gitignore   => [
                  '*.pyc',
                  '*.swp',
                 ],
```


# The data type `Confkeeper::ExportedRepos`

This data type represents a list of git repositories **in
the collector**. It's a hash where each key is the fqdn of a
host and each value represents the repositories provided by
the host. Here is an example of this structure:

```puppet
# We assume that these variables match with `Confkeeper::GitRepositories`.
$repositories_srv_1 = ...
$repositories_srv_2 = ...

$exported_repos = {
  'srv-1.dom.tld' => {
    account      => 'root', # Optional.
    ssh_pubkey   => 'ssh-rsa AAAA3aC1yc2E...Ip root@srv-1.dom.tld',
    repositories => $repositories_srv_1,
  }
  'srv-2.dom.tld' => {
    account      => 'root', # Optional.
    ssh_pubkey   => 'ssh-rsa AAAA3dd1ye2a...mL root@srv-2.dom.tld',
    repositories => $repositories_srv_2,
  }
}
```

For each fqdn (each key), the `account` key is optional. If
not present, the default value is `'root'`. The `ssh_pubkey`
value is the content of a ssh public key (for instance the
complete content of a file `id_rsa.pub`). For instance, with
the `repositories` value `$repositories_srv_1` above, the
gitolite user `root@srv-1.dom.tld` (ie `<account>@<fqdn>`)
will be created in the collector related to the ssh public
key given by the `ssh_pubkey` value (which will be created
too in the collector).


# The data type `Confkeeper::AllinoneReader`

This data type represents a gitolite user which will be able
to read all git repositories in the collector, except the
specific git repository `gitolite-admin` only readable (and
writable) by the `admin` gitolite user. Here is an example
of this structure:

```puppet
$a_all_in_on_reader = {
  username   => 'bob',
  ssh_pubkey => 'ssh-rsa AAAA3dd1ye2a...mL bob@my.desktop.tld',
}
```

Each key is required. The `usernmae` value mustn't be
`admin` or `git` which are reserved. The `ssh_pubkey` value
is the content of a ssh public key (for instance the
complete content of a file `id_rsa.pub`).


# Usage

Here is an example:

```puppet
# Additional exported git repositories for hosts where
# Puppet is not available.
$additional_exported_repos = {
  'old-srv1.dom.tld' => {
    account      => 'root',
    ssh_pubkey   => 'ssh-rsa AAAA3aC1yc2E...Ip root@old-srv1.dom.tld',
    repositories => {
                      '/etc'       => {},
                      '/usr/local' => {},
                      '/opt'       => {},
                    },
  }
  'switch1.dom.tld' => {
    account      => 'admin',
    ssh_pubkey   => 'ssh-rsa AAAATaa1ycEd...yt root@oswitch1.dom.tld',
    repositories => {
                      '/config' => {},
                    },
  }
}

$allinone_readers = [
  {
    username   => 'bob',
    ssh_pubkey => 'ssh-rsa AAAA3dd1ye2a...mL bob@my.desktop.tld',
  },
  {
    username   => 'alice',
    ssh_pubkey => 'ssh-rsa AAAAy7u1eeDt...pf alice@my.desktop.tld',
  },
}

# 1. For the collector.
class { '::confkeeper::collector::params':
  collection                => 'all',
  address                   => $::facts['networking']['fqdn'],
  ssh_host_pubkey           => $::facts['ssh']['rsa']['key'],
  wrapper_cron              => '/usr/bin/wrapper_cron --name update-all-in-one --',
  additional_exported_repos => $additional_exported_repos,
  allinone_readers          => $allinone_readers,
}

include '::confkeeper::collector'


# 2. For a provider.
$repositories = {
  '/etc'       => {'gitignore' => undef},
  '/usr/local' => {},
  '/opt'       => {'gitignore' => ['/puppetlabs/']}, # exclude /opt/puppetlabs/
}

class { '::confkeeper::provider::params':
  collection           => 'all',
  repositories         => $repositories,
  wrapper_cron         => '/usr/bin/wrapper_cron --name push-all-repos --',
  fqdn                 => $::facts['networking']['fqdn'],
  etckeeper_ssh_pubkey => $::facts['etckeeper_ssh_pubkey'],
}

include '::confkeeper::provider'
```


# Parameters of the class `confkeeper::collector::params`

The `collection` parameter is a string to define the set of
providers that the collector will retrieve. In a given
collection, it must have only one collector. It should have
multiple providers of course but there is only one collector
for a given collection (a collector can be a provider too).
The default value of this parameter is `'all'`.

The `address` parameter is the address (fqdn or IP address
etc.) of the collector. In fact, this parameter is not used
at all by the collector. This parameter is retrieved and
used by the providers via the Puppetdb. This address is
required by providers to push its git repositories (via a
cron task). The default value of this parameter is
`$facts['networking']['fqdn']` and normally you shouldn't
change this value.

The parameter `ssh_host_pubkey` is the value of a ssh host
public key of the collector. This parameter is not used at
all by the collector. This parameter is used by the
providers via the Puppetdb to avoid the warning concerning
the fingerprint during a git push. The default value of this
parameter is `$facts['ssh']['rsa']['key']` and normally you
shouldn't change this value.

The `wrapper_cron` parameter can be useful for the cron task
which is launched daily to put all git repositories (except
the specific repository `gitolite-admin`) in a unique and
special all-in-one and non-bare git repository. It's just
for convenience. The parameter `wrapper_cron`, if defined,
allows to add a wrapper script to monitor the cron task. The
default value of this parameter is `undef`: in this case,
the cron task has no wrapper script.

Concerning the all-in-one repository:

```
Its local path in the collector: /home/git/all-in-one.git
Its remote URL:                  git@${address-of-the-collector}:all-in-one.git
```

The `additional_exported_repos` allows to add "manual"
repositories in the collector. Indeed, the collector of a
given collection retrieves by default all the git
repositories from all the providers in the same collection.
But sometimes, you want to add git repositories from hosts
where puppet is not available and/or not installed. This is
the goal of the parameter `additional_exported_repos` which
must match with the data type `Confkeeper::ExportedRepos`.
Its default value is `{}` ie no additional git repository.

The `allinone_readers` parameter allows to add gitolite
users which will be able to read (but not able to write) the
special "all-in-one" repository. This parameter must match
with `Array[Confkeeper::AllinoneReader]` and its default
value is `[]` ie no "all-in-one" reader (except `git` which
is the account used to created this "all-in-one" repository
and the user `gitolite-admin` which can read and write in
all repositories).


# Parameters of the class `confkeeper::provider::params`

The `collection` parameter is a string to define the set to
which the provider belongs. In a given collection, it must
have only one collector but it should have multiple
providers of course. The default value of this parameter is
`'all'`.

The `repositories` parameter must match with the data type
`Confkeeper::GitRepositories`. It defines the local git
repositories which will be daily commited and pushed to the
remote collector. Its default value is:

```puppet
{
  '/etc'       => {'gitignore' => undef},
  '/usr/local' => {},
  '/opt'       => {'gitignore' => ['/puppetlabs/']},
}
```

The default merge policy of this parameter is `hash`.

The repository `/usr/local` is special because, before the
commit-and-push, all the bash histories (in
`/root/.bash_history` and in `/home/*/.bash_history`) are
copied in `/usr/local/bash-history/`.

The `wrapper_cron` parameter can be useful for the cron task
which is launched daily to commit and push (to the
collector) all the local git repositories of the provider.
The parameter `wrapper_cron`, if defined, allows to add a
wrapper script to monitor this cron task. The default value
of this parameter is `undef`: in this case, the cron task
has no wrapper script.

The `fqdn` parameter is not really used by the provider
except for some default values of the `repositories`
parameter. The parameter is mostly used by the collector to
sort the remote git repositories (in the collector) in
specific directories. For instance, all the git repositories
of the provider where the `fqdn` parameter is equal to
`srv1.dom.tld` will be put in the directory
`/home/git/srv1.dom.tld/` in the collector. The default
value of this parameter is `$::facts['networking']['fqdn']`
and you should probably not change this value.

The `etckeeper_ssh_pubkey` parameter is not really used in
the `provider` class. It's the ssh public key used by the
provider to push its local git repositories. The default
value of this parameter is `$facts['etckeeper_ssh_pubkey']`
which is a custom fact of this module and you shouldn't
change this value. In fact, this parameter is used by the
collector via Puppetdb to retrieve the ssh public key used
by the provider and create a gitolite user related to this
key.


# The timing of puppet runs between the collector and the providers

For a given collection, first, you have to install the
collector. When the collector is installed and **only when
the collector is installed**, you can install providers.

1. During the first puppet run of a provider, the custom
   fact `$facts['etckeeper_ssh_pubkey']` is loaded but the
   ssh public key is not created yet (indeed the key is created
   during the puppet run *after* the loading of facts). So the
   fact is `undef` during the first puppet run. The
   installation of the provider will be done during the first
   puppet run but the provider will not be taken into account
   by the collector because the custom fact
   `$facts['etckeeper_ssh_pubkey']` is `undef` and this key is
   required by the collector to create a gitolite user related
   to the provider host.

2. During the second puppet run of the provider, the custom
   fact `$facts['etckeeper_ssh_pubkey']` is not undefined
   (because the ssh key has been created during the first
   puppet run). After this second puppet run, the provider is
   finally candidate as provider by the collector.

3. Now, during a puppet run in the collector, the git
   repositories of the provider will be created and, after
   that, commits and pushs will be possible in the provider
   (via the cron task).

In a provider, the cron task which commits and pushes in all
local git repositories is launched daily at a random time
between 18:00 and 23:59.

In a collector, the cron task which collects all
repositories of the collection in the all-in-one repository
is launched daily at a random time between 01:00 to 06:59.



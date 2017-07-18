# TODO

* Add a parameter to add specific gitolite account which will be "all-in-one.git" readers.
* Make a completed readme file.


```puppet
exported_repos = {
  fqdn1 => {
    account      => 'root', # <= Optional, default is "root".
    ssh_pubkey   => 'xxx....xxx',
    repositories => {
      '/path/foo/bar' => {
        relapath    => 'fqdn1/path-foo-bar.git',                        # <= Opiotnal.
        permissions => [{'rights' => 'RW+', 'target' => "root@fqdn1"}], # <= Optional.
        gitignore   => [],                                              # <= Optional.
      }
      # ...
    }
  }
  # ...

}
```

# Module description

Module to export configurations in a server, the collector.
With the class `confkeeper::collector`, you can install a
collector (via gitolite) and with the class
`confkeeper::provider`, you can install a provider, ie a
host which will export its configuration (via etckeeper).


# The type `Confkeeper::GitRepositories`

This data type represents a list of git repositories in a
provider which will be copied in the collector. It's a hash
where each key is the local path of a git directory (the
path mustn't have a trailing slash). Here is an example of
data type `Confkeeper::GitRepositories`:

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
                      gitignore   => undef
                     },
  '/usr/local'    => {
                      # Use all default values.
                     },
  '/opt'          => {
                      gitignore   => ['/puppetlabs/'] # exclude the directory /opt/puppetlabs/.
                     },
}
```

For each local repository (each key), the value has this
structure:

```puppet
# Just for convenience:
$fqdn = $facts['networking']['fqdn']


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
  # user which corresponds to a ssh key pair automatically
  # created by Puppet in the provider and the public ssh key
  # is automatically exported in the collector server.
  permissions => [
                  {'rights' => 'RW+', 'target' => "root@${fqdn}"},
                 ],

  # To define the content of the .gitignore in the git
  # repository. It's an array where a element is a line in
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



# Usage

Here is an example:

```puppet
# For the collector.
class { '::confkeeper::collector::params':
  collection                => 'all',
  address                   => $::facts['networking']['fqdn'],
  ssh_host_pubkey           => $::facts['ssh']['rsa']['key'],
  wrapper_cron              => undef,
  additional_exported_repos => {},
  allinone_readers          =>,
}

include '::confkeeper::collector'

$repositories = {
  '/etc'       => {'gitignore' => undef},
  '/usr/local' => {},
  '/opt'       => {'gitignore' => ['/puppetlabs/']}, # exclude /opt/puppetlabs/
}

# For a provider.
class { '::confkeeper::provider::params':
  collection           => 'all',
  repositories         => $repositories,
  wrapper_cron         => undef,
  fqdn                 => $::facts['networking']['fqdn'],
  etckeeper_ssh_pubkey => $::facts['etckeeper_ssh_pubkey'],
}

include '::confkeeper::provider'
```




# Parameters of the class `confkeeper::collector::params`

The `collection` parameter is a string to define the set of
providers that the collector will retrieve. In a given
collection, it must have only one collector. It should have
several providers but there is only one collector (a
collector can be a provider too). The default value of this
parameter is `'all'`.

The `address` parameter is the address (fqdn or IP address
etc.) of the collector. In fact, this parameter is not used
at all by the collector. This parameter is used by the
providers via the Puppetdb. This address is required by
providers to push configurations. The default value of this
parameter is `$facts['networking']['fqdn']` and normally you
shouldn't change this value.

The parameter `ssh_host_pubkey` is the value of a ssh host
public key of the collector. This parameter is not used at
all by the collector. This parameter is used by the
providers via the Puppetdb to avoid warning concerning the
fingerprint during a git push. The default value of this
parameter is `$facts['ssh']['rsa']['key']` and normally you
shouldn't change this value.

The `wrapper_cron` parameter 



TODO...



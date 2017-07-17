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



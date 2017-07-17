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




# Parameters

TODO...



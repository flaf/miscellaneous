# Module description

A module to upgrade and reboot a host automatically.




# Usage

Here is an example:

```puppet
class { '::autoupgrade::params':
  apply                  => true,
  hour                   => fqdn_rand(6, $seed),  # from 0 to 5.
  minute                 => fqdn_rand(60, $seed), # from 0 to 59.
  monthday               => absent,               # ie * (any day of the month).
  month                  => absent,               # ie * (any month).
  weekday                => fqdn_rand(7, $seed),  # from 0 to 6.
  reboot                 => true,
  commands_before_reboot => [],
  puppet_run             => true,
  puppet_bin             => '/opt/puppetlabs/bin/puppet',
}

include '::autoupgrade'
```




# Parameters

The parameter `apply`



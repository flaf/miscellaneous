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
  upgrade_wrapper        => undef,
}

include '::autoupgrade'
```




# Parameters

When the parameter `apply` is set to `false`, automatic
upgrades are disabled and all cron tasks are removed so that
the module does nothing. If set to `true`, automatic upgrades
are enabled. The default value of this parameter is `false`.

The parameters `hour`, `minute`, `monthday`, `month` and
`weekday` define when the upgrade cron task is launched. The
default values of these parameters are displayed in the
example above (ie one automatic upgrade peer week).

The boolean `reboot` tells if the node must reboot after
each automatic upgrade. If set to `true`, the default, a
reboot is triggered after each upgrade. If set to `false`,
there is no reboot after the upgrade.

The parameter `commands_before_reboot` is an array of shell
commands which are executed before a reboot (only the
reboots triggered by an automatic upgrade). The default
value of this parameter is `[]` ie no commands are executed
before the reboot.

The boolean `puppet_run` tells if the node must execute a
puppet run after each automatic upgrade. If `reboot` is set
to `true`, the puppet run will not be executed just after
the automatic upgrade but just after the reboot.

The parameter `puppet_bin` is the path of the puppet binary.
Its default value is `/opt/puppetlabs/bin/puppet`.

The `upgrade_wrapper` parameter is a command that you can
use to wrap the script which makes the automatic upgrades
(can be usefull in monitoring for instance). The default
value of this parameter is `undef`, ie no wrapper.



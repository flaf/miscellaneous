# Module description

A module to upgrade and reboot a host automatically.




# Usage

Here is an example:

```puppet
$seed = 'autoupgrade-puppet'

class { '::autoupgrade::params':
  apply                  => true,
  hour_range             => [0, 5],
  hour                   => undef,
  minute                 => fqdn_rand(60, $seed), # from 0 to 59.
  monthday               => absent,               # ie * (any day of the month).
  month                  => absent,               # ie * (any month).
  weekday                => fqdn_rand(7, $seed),  # from 0 to 6.
  reboot                 => true,
  commands_before_reboot => [],
  puppet_run             => true,
  flag_no_puppet_run     => '/etc/puppetlabs/puppet/no-run',
  puppet_bin             => '/opt/puppetlabs/bin/puppet',
  upgrade_wrapper        => undef,
  upgrade_subcmd         => 'dist-upgrade',
  apt_clean              => true,
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
example above (ie one automatic upgrade peer week). The
default value of `hour` is `undef`. In this case, the hour
of the cron task is chosen randomly in the range given by
the parameter `hour_range`. For instance, with the value
`[0, 5]`, which is the default, the hour of the cron can be
0, 1, 2, 3 or 4 (5 is excluded). If the value of the `hour`
parameter is not `undef`, its value takes the precedence
but, if it's an integer, it must belong to the range given
by the value of the parameter `hour_range`.

**Remark:** the function `autoupgrade::get_final_hour()`
(which has no parameter) gives the final value of the cron
hour. It can be useful when the parameter
`autoupgrade::hour` is `undef`. If not, the function just
returns the value of the parameter `autoupgrade::hour`.
Warning, this function makes an include of the class
`autoupgrade::params`.

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

The parameter `flag_no_puppet_run` is the path of a file
which completely disables any puppet run during the
automatic upgrades if this file is present (as regular file,
even an empty file works). So if this file is present, even
with `puppet_run` set to `true`, any puppet run will be
launched. The default value of this parameter is
`'/etc/puppetlabs/puppet/no-run'`.

The parameter `puppet_bin` is the path of the puppet binary.
Its default value is `/opt/puppetlabs/bin/puppet`.

The `upgrade_wrapper` parameter is a command that you can
use to wrap the script which makes the automatic upgrades
(can be usefull in monitoring for instance). The default
value of this parameter is `undef`, ie no wrapper.

The parameter `upgrade_subcmd` can take only 2 values:
`'upgrade'` or `'dist-upgrade'` (the default) which are
subcommands from the `apt-get` command.

The parameter `apt_clean` is a boolean to trigger a `apt-get
clean` after the upgrade if set to `true`, which is its
default value. It allows to avoid a swelling of the
`/var/cache/apt/archives/` directory.



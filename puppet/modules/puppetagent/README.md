# Module description

This module configures the puppet agent (ie the client).


# Usage

Here is an example:

```puppet
# This module uses the "params" pattern.

class { '::puppetagent::params':
  service_enabled   => false,
  runinterval       => '7d',
  server            => 'puppet4.mydomain.tld',
  ca_server         => '$server',
  cron              => {'per-week' => {}},
  cron_hour_range   => [10, 15],
  puppetconf_path   => '/etc/puppetlabs/puppet/puppet.conf',
  manage_puppetconf => true,
  dedicated_log     => true,
  ssldir            => '/etc/puppetlabs/puppet/ssl',
  bindir            => '/opt/puppetlabs/puppet/bin',
  etcdir            => '/etc/puppetlabs/puppet',
  flag_puppet_cron  => '/etc/puppetlabs/puppet/no-run-via-cron',
}

include '::puppetagent'
```




# Parameters and default values

The `service_enabled` parameter is a boolean to tell
if you want enable the `puppet` daemon, ie the client
daemon ("enable" means "the service will be automatically
started at each reboot"). If the daemon is enabled, then
the puppet run will be launched with the `runinterval`
frequency. The default value of `service_enabled` is
`false` and the default value of `runinterval` is
the string `'7d'`.

The `server` parameter is the value of the `server`
parameter in the file `puppet.conf` of the client.
Its default value is `$::server_facts['servername']`
if defined (generally when the `trusted_server_facts`
parameter is set to `true` in the file `puppet.conf`
of the server), else it's just the string `puppet`.

The `ca_server` parameter is a string to define the CA
server in the `puppet.conf` file. This parameter is
necessary during the first and the second puppet run where
the client does some SSL operations. The default value of
this parameter is the string `$server`, ie the CA server is
the same as the puppetmaster.

The `cron` parameter can be a string with only 3 possible
values:

- `per-day` for per-day cron  (hour and minute chosen randomly),
- `per-week` for per-week cron (hour, minute and weekday chosen randomly),
- `disabled`where no cron will run puppet.

For a cron per day or per week, it's possible to force the
minute and the hour of the cron task (and the weekday too
for a cron per week). In these cases, you can set the
parameter `cron` to a hash. For instance:

```puppet
$cron = {
  'per-day' => {
    'hour'   => 23, # Optional.
    'minute' => 58, # Optional.
  }
}

# With a cron per week, you can set the weekday too :
$cron = {
  'per-week' => {
    'weekday' => 2   # Optional.
    'hour'    => 23, # Optional.
    'minute'  => 58, # Optional.
  }
}
```

With the hash form, if a key is not present (for instance
`minute`), a random value will be used automatically. The
default value of the `cron` parameter is `'per-week'` (ie
just the string). The cron task do absolutely nothing if the
file `${etcdir}/no-run-via-cron` exists (it's a basic way to
temporarily disable the cron task).

For the random hour, you can force a range with the
parameter `cron_hour_range`. For instance with
`cron_hour_range => [10, 22]`, the hour of the cron will be
chosen between 10:00 and 22:00 (21:59 in fact). The default
value of this parameter is `[0, 24]`.

If the key `'hour'` is present in the `cron` parameter, the
value of `'hour'` takes the precedence but must belong to
the "hour" range given by the value of the `cron_hour_range`
parameter. If not, the module raises an error.

The `puppetconf_path` parameter is a non-empty string and
its default value is `'/etc/puppetlabs/puppet/puppet.conf'`.
Normally you should never change this parameter.

The `manage_puppetconf` parameter is a boolean. If set
to `false`, the puppet class will not manage the
`puppet.conf` file. The goal of this parameter is to
use this puppet class in a generic module and be able
to disable the management of the `puppet.conf` file
for specific nodes like puppet servers which will
probably use a `puppetserver` module where the
`puppet.conf` file will be managed. For these kind
of nodes, you can just add this line:

```yaml
puppetagent::manage_puppetconf: false
```

in the `$fqdn.yaml` file of these specific nodes.
The default value of this parameter is `true`.

If set to `true`, the boolean `dedicated_log` allows to put
all logs from the puppet agent in the dedicated log file
`/var/log/puppet-agent.log` and no longer in syslog.
Furthermore, this dedicated log file will have restrictive
Unix rights (0600 instead of 0640 for syslog). The default
value of this parameter is `true`. If set to `false`, the
logs of puppet agent will be put in syslog (the default
behaviour of the puppet agent).

The `ssldir` parameter is a non-empty string and its default
value is `'/etc/puppetlabs/puppet/ssl'`. Normally you should
never change this parameter.

The `bindir` parameter is a non-empty string and its default
value is `'/opt/puppetlabs/puppet/bin'`. Normally you should
never change this parameter.

The `etcdir` parameter is a non-empty string and its default
value is `'/etc/puppetlabs/puppet'`. Normally you should
never change this parameter.

The parameter `flag_puppet_cron` is the path of a file which
disables the puppet runs via cron. Indeed, if this file is
present, even if it is empty, the cron script which triggers
a puppet run will do absolutely nothing. The default value
of this parameter is `'/etc/puppetlabs/puppet/no-run-via-cron'`
and normally you should never change this parameter.


# Manual installation of the puppet agent

Normally, the installation of the puppet-agent is "manual".
Here is the commands:

```sh
# Should be already installed.
apt-get install lsb-release

# Key which expires in 2019-02-11.
KEY=$(echo 6F6B 1550 9CF8 E59E 6E46  9F32 7F43 8280 EF8D 349F | tr -d ' ')
apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys "$KEY"
#
# Or you can just do:
#
#   wget http://apt.puppetlabs.com/pubkey.gpg -O - | apt-key add -
#

COLLECTION='PC1'
distrib=$(lsb_release -sc)
collection=$(echo $COLLECTION | tr '[:upper:]' '[:lower:]')

echo "# Puppetlabs $COLLECTION $distrib Repository.
deb http://apt.puppetlabs.com $distrib $COLLECTION
#deb-src http://apt.puppetlabs.com $distrib $COLLECTION
" > /etc/apt/sources.list.d/puppetlabs-$collection.list

# Force the version number as below.
apt-get update && apt-get install puppet-agent=1.2.4-*
```

After that, you can run the first puppet run:

```sh
# For a classical puppet client of the Puppet CA:
/opt/puppetlabs/bin/puppet agent --test --server=$server

# If you want to install a 'autonomous' puppetserver:
/opt/puppetlabs/bin/puppet agent --test --server=$server --ssldir=/etc/puppetlabs/puppet/sslagent
rm -r /etc/puppetlabs/puppet/sslagent
# After installation, you can run the next puppet run like this:
/opt/puppetlabs/bin/puppet agent --test

# For a 'client' puppetserver.
/opt/puppetlabs/bin/puppet agent --test --server=$server

# For a puppet client of a 'client' puppetserver:
/opt/puppetlabs/bin/puppet agent --test --server=$server --ca_server=$ca_server
```





# Module description

This module configures the puppet agent (ie the client).




# Usage

Here is an example:

```puppet
class { '::puppetagent':
  service_enabled   => false,
  runinterval       => '7d',
  server            => 'puppet4.mydomain.tld',
  ca_server         => '$server',
  cron              => 'per-week',
  manage_puppetconf => true,
}
```




# Parameters and default values

The `service_enabled` parameter is a boolean to tell
if you want enable the `puppet` daemon, ie the client
daemon ("enable" means "the service will be automatically
started at each reboot). If the daemon is enabled, then
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

The `ca_server` parameter is a string to define the
CA server. This parameter is necessary during the
the first and the second puppet run where the client
do some SSL operations. The default value of this
parameter is the string `$server`, ie the CA server
is the same as the puppetmaster.

The `cron` parameter accepts only 3 values :
- `per-day` for per-day cron,
- `per-week` for per-week cron,
- `disabled`where no cron will run puppet.
Its default value is `per-week`.

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




# TODO

* Add a feature to be able to launch puppet run
by a cron task. It seems to me a better way than
a running daemon.





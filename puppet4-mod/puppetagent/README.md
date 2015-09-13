# Module description

This module configures the puppet agent (ie the client).




# Usage

Here is an example:

```puppet
class { '::puppetagent':
  service_enabled => false,
  runinterval     => '7d',
  server          => 'puppet4.mydomain.tld',
  disable_class   => false,
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

The `disalbe_class` parameter is a boolean. If set
to `true`, the puppet class do absolutely nothing.
The goal of this parameter is to use this puppet
class in a generic module and be able to disable
this class for specific nodes like puppet servers
just by adding this line:

```yaml
puppetagent::disable_class: true
```

in the `$fqdn.yaml` file of these specific nodes.
The default value of this parameter is `false`.




# TODO

* Add a feature to be able to launch puppet run
by a cron task. It seems to me a better way than
a running daemon.





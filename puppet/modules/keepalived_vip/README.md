# Module description

This module allows to set multiple VIPs in a server via
Keepalived.


# Usage

Here is an example via a hiera configuration:

```yaml
keepalived_vip::params::vrrp_instances:
  vip_lb:           # <== The name of the vrrp_instance
    virtual_router_id: 60
    state: 'BACKUP'
    nopreempt: true # <== Optional and default is false if not present
    interface: 'eth0'
    priority: 100
    auth_type: 'PASS'
    auth_pass: 'xxxxxxxxxxxxxxx'
    virtual_ipaddress: [ '192.168.0.100' ]
    track_script:       # <== Optional and default is undef if not present
      script: 'pkill -0 haproxy'
      interval: 2
      weight: 0
  vip_mysql:        # <== The name of the vrrp_instance
    virtual_router_id: 70
    state: 'BACKUP'
    nopreempt: true # <== Optional and default is false if not present
    interface: 'eth1'
    priority: 100
    auth_type: 'PASS'
    auth_pass: 'xxxxxxxxxxxxxxx'
    virtual_ipaddress: [ '192.168.0.200' ]
    track_script:       # <== Optional and default is undef if not present
      script: 'pkill -0 mysqld'
      interval: 2
      weight: 0
```

If the several vrrp instance share the same track script,
you can use the `vrrp_scripts` like this:

```yaml
keepalived_vip::params::vrrp_scripts:
  check_haproxy: # Name of the vrrp_script instance
    script: 'pkill -0 haproxy'
    interval: 2
    weight: 0
  check_mysql:
    script: 'pkill -0 mysqld'
    interval: 2
    weight: 0

keepalived_vip::params::vrrp_instances:
  vip_lb_foo:    # Name of the vrrp_script instance
    virtual_router_id: 60
    state: 'BACKUP'
    nopreempt: true
    interface: 'eth0'
    priority: 100
    auth_type: 'PASS'
    auth_pass: 'xxxxxxxxxxxxxxx'
    virtual_ipaddress: [ '192.168.0.100' ]
    track_script: 'check_haproxy' # A string, must be a key of "vrrp_scripts" above
  vip_lb_bar:
    virtual_router_id: 70
    state: 'BACKUP'
    nopreempt: true
    interface: 'eth1'
    priority: 100
    auth_type: 'PASS'
    auth_pass: 'xxxxxxxxxxxxxxx'
    virtual_ipaddress: [ '192.168.0.200' ]
    track_script: 'check_haproxy' # A string, must be a key of "vrrp_scripts" above
```

There are 2 another parameters:

```yaml
keepalived_vip::params::cron_check_vip: false                      # the default value
keepalived_vip::params::cron_check_cmd: '/usr/local/bin/check-vip' # the default value


```


# The parameters of the `keepalived_vip::params` class

The `vrrp_instances` parameter must be a hash with the
structure above. An empty hash `{}` is not allowed (it will
raise an error). This parameter has no default value (even
the `undef` value) and must be provided by the user. The
default merging of this parameter is `deep`.

In the `vrrp_instances` parameter, the key `track_script`
can be:

- a string and in this case it must be a key of the
  `vrrp_scripts` parameter (see below);
- an explicit hash (you can see its structure in the first
  example above);
- `undef` (`null` in hiera) in this case the vrrp instance
  has no `track_script` instruction;
- or can be just absent which is equivalent to set to `undef`.

In the `vrrp_instances` parameter, the key `nopreempt` can be
absent. In this case, its default value is `false`.

The `vrrp_scripts` parameter must be a hash with the
structure above. The default value is `{}` (an empty hash).
In this case, you must define the `track_script` value in
`vrrp_instances` via an explicit hash (see the first example
above). If not, you can use a string to refer to a key of
the `vrrp_scripts` parameter.

The `cron_check_vip` parameter is a boolean to tell if
a cron task must be set to check if all VIPs are well
present in the host. The default value of this parameter
is `false`, ie no cron task.

The `cron_check_cmd` parameter is a string of the command
used by the cron task above (if present). The default value
of this parameter is `'/usr/local/bin/check-vip'` which is
a script automatically managed by Puppet if the cron task
is present.



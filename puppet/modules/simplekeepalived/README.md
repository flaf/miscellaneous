# Module description

A module to manage a simple VRRP instance with Keepalived.




# Usage

Here is an example:

```puppet
class { '::simplekeepalived::params':
  virtual_router_id => 28,
  interface         => 'eth0',
  priority          => 100,
  nopreempt         => true,
  auth_pass         => '1234567890abcd',
  virtual_ipaddress => [
                        {'address' => '192.168.0.199/24', 'label' => 'vip1'},
                        {'address' => '192.168.0.200/32', 'label' => 'vip2'},
                       ],
  track_script      => {
                        'script'   => '/usr/local/bin/check arg1 arg2',
                        'interval' => 2,
                        'weight'   => 0,
                        'fall'     => 2,
                        'rise'     => 1,
                       },
}

include '::simplekeepalived'
```




# Parameters

The parameter `virtual_router_id` is an arbitrary unique
number from 0 to 255. This number must be unique in a VLAN.
This parameter has no default value.

The parameter `interface` is the interface bound by the VRRP
instance. The default value of this parameter is
`$::facts['networking']['primary']`.

The parameter `priority` allow to set the priority of the
VRRP instance. For electing MASTER, highest priority wins,
unless the parameter `nopreempt` is `true`. The default
value of the parameter `priority` is `true`.

The parameter `nopreempt` allows the lower priority machine
to maintain the master role, even when a higher priority
machine comes back online. The default value of this
parameter is `true`.

The parameter `auth_pass` allows to set the password used by
the nodes to communicate. This parameter has no default
value.

The parameter `virtual_ipaddress` must have the same
structure above and it allows to set the VIP. This parameter
is an array that can only contain one VIP. This parameter
has no default value.

The parameter `track_script` can be `undef` or must be a
hash with the structure above where only the key `script` is
mandatory. The others keys are optional with the default
values in the example above. This script sets the VRRP
instance to the `FAULT` state if its exit code is not zero.




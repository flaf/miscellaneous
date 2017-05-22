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




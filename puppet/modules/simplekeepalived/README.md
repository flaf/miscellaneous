TODO: Please, make a real README file...

# Module description

A module to manage a simple VRRP instance with Keepalived.




# Usage

Here is an example:

```puppet
class { '::simplekeepalived':
  # ...
}
```


```yaml
virtual_router_id: 28
interface: 'eth0'      # default == $::facts['networking']['primary']
priority: 100          # default == 100
nopreempt: true        # default == true
auth_pass: '1234567890'
virtual_ipaddress:
  - address: '192.168.0.199/24'
    label: 'vip'
    # <=> '192.168.0.199/24 broadcast 192.168.0.255 dev eth0 label eth0:vip'
track_script:          # default == undef
  script: "/usr/local/bin/check"
  interval: 2 # default == 2
  weight: 0   # default == 0
  fall: 2     # default == 2
  rise: 1     # default == 1
```


# Parameters

TODO...



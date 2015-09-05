# Module description

This module implements a configuration of the
`/etc/network/interfaces` file.




# Usage

Here is some examples:

```puppet
# A basic example.
class { '::network':
  interfaces => {
    eth0 => {
      inet => {
        method => 'dhcp',
      },
    },
  },
}

# A more complex example.
class { '::network':
  restart    => true, # Not recommended.
  interfaces => {
    eth0 => {
      macaddress => '00:1c:cf:50:0b:51',
      comment    => [ 'This is the MySQL interface.' ],
      inet       =>  {
        method  => 'static',
        options => {
          address   => '192.168.1.123',
          network   => '192.168.1.0',
          netmask   => '255.255.255.0',
          broadcast => '192.168.1.255',
      },
    },
    eth1 => {
      macaddress => '00:1c:cf:50:0b:52',
      comment    => [ 'This is the management interface.' ],
      inet       =>  {
        method  => 'static',
        options => {
          address   => '172.31.0.123',
          network   => '172.31.0.0',
          netmask   => '255.255.0.0',
          broadcast => '172.31.255.255',
          gateway   => '172.31.0.1',
      },
    },
  },
}
```

The `restart` parameter is a boolean. If the value
is `true`, then the network will be restarted after
an update of the network configuration.

In the `interfaces` parameter, for each interface,
you can put:

* a `inet` configuration (for IPv4)
* and/or a `inet6` configuration (for IPv6),
* a `macaddress` key (optional),
* a `comment` key (optional),

At least a `inet` or a `inet6` hash must exist
in each interface. In each `inet` or `inet6` hash:

* the `method` key is mandatory
* and the `options` key can be optional in some cases
(for instance when the interface is configured with
the `dhcp` method).

If the `macaddress` key is provided, then the value
of this key will be put as comment in the file
`/etc/network/interfaces`. Furthermore, a udev rule
will be set in order to ensure that the interface
with the provided macaddress has really the name
stated in the `interfaces` parameter.

The `comment` key must be an array of strings.
Each string in this array is a line of comment
just above the interface settings in the file
`/etc/network/interfaces`.

**Remark:** bonding and bridging are allowed.




# Data binding

In the `network::data()` function, there is a lookup
of these keys:

* `inventory_networks`,
* `interfaces`

with the `lookup()` function. Theses keys **must be**
found in hiera or in the environment (via the
`environment::data()` function) because no default
values are provided. For these keys, the lookup
uses a hash-merging.

In yaml format, the `inventory_networks` has this
form:

```yaml
inventory_networks:
  admin_mgt:
    comment: [ 'Network dedicated to management.' ]
    vlan_id: '1000'
    vlan_name: 'admin_mgt'
    cidr_address: '172.31.0.0/16'
    gateway: '172.31.0.1'
    dns: [ '172.31.10.1', '172.31.10.2' ]
    ntp: [ '172.31.11.1', '172.31.11.2', '172.31.11.3' ]
  mysql:
    comment: [ 'Network dedicated to MySQL.' ]
    vlan_id: '1001'
    vlan_name: 'mysql'
    cidr_address: '192.168.1.0/24'
```

The value of this `inventory_networks` key must be a hash.
Here is the **mandatory** sub-keys for each network:

* `comment` (each element of this array is a line of comment),
* `vlan_id`,
* `vlan_name`,
* `cidr_address`.

But you can add other sub-keys like in the example above
(with the `gateway` sub-key for instance). The key which
represents the name of the IP network (ie `admin_mgt` and
`mysql` in this example above) is generally the same string
as the `vlan_name` value but not always (for instance in the
same VLAN you can have a IPv4 and IPv6 networks).

The value of this `interfaces` key must be a hash with
the same form as the `interfaces` parameter of the `::network`
class but you can add the optional `in_networks` key and put
`__default__` values like this:

```yaml
interfaces:
  eth0:
    in_networks: [ 'mysql' ]
    macaddress: '00:1c:cf:50:0b:51'
    comment: [ 'This is the MySQL interface.' ]
    inet:
      method: 'static'
      options:
        address: '192.168.1.123'
        network: '__default__'
        netmask: '__default__'
        broadcast: '__default__'
  eth1:
    in_networks: [ 'admin_mgt' ]
    macaddress: '00:1c:cf:50:0b:52'
    comment: [ 'This is the management interface.' ]
    inet:
      method: 'static'
      options:
        address: '172.31.0.123'
        network: '__default__'
        netmask: '__default__'
        broadcast: '__default__'
        gateway: '__default__'
```

The `in_networks` key is optional for a given interface
but must be present if you use at least one `__default__`
value for this interface. In this case, the `__default__`
will replaced by the relevant value in the
`inventory_networks` hash (the first network provided in
the array `in_networks` will be used). To be more precise,
with `xxx: '__default__'`, the value will be replaced by
the value of `xxx` in the `inventory_networks` hash,
except if `xxx` is `network`, `netmask` or `broadcast`
where the `cidr_address` of the `inventory_networks` hash
will be used to deduce the right value.

The `comment` key is a little special. The final value will
not be the value in the `interfaces` key. The `comment`
values will be concatenate between the `inventory_networks`
key and the `interfaces` key (if no comment are give in
the `interfaces` key just the comment in the
`inventory_networks` key will be used).

In addition of the 2 yaml examples above, if you add too
this entry in hiera:

```yaml
# Not recommended.
network::restart: true
```

then you will have a call completely equivalent to the
call of the class given in the "complex" example in the
"usage" part with just this:

```puppet
include '::network'
```




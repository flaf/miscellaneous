# TODO

* README not updated. The documentation concerning the
class `network::resolv_conf` is missing.
* Create a class `network::host`.




# Module description

This module implements a configuration of the
`/etc/network/interfaces` file and some others
basic network configurations.


# The `network` class

## Usage

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
  },
}
```

**Warning:** these calls above will probably fail if used
verbatim because of the choice concerning the data binding
for this module. See below for more details.


The `restart` parameter is a boolean. If the value
is `true`, then the network will be restarted after
an update of the network configuration.

In the `interfaces` parameter, for each interface,
you can put:

* a `inet` configuration (for IPv4)
* and/or a `inet6` configuration (for IPv6),
* a `macaddress` key mapped to a non-empty string (optional),
* a `comment` key mapped to a non-empty array of
non-empty strings (optional),

In each interface, at least a `inet` key or a `inet6`
key must exist and the mapped value must be a hash.
In each `inet` and `inet6` hash, you can put:

* a `method` key which is mandatory,
* and a `options` key which is syntactically optional
but, in some cases, if you want to have a functional
network configuration this key will be required
(for instance when the interface is configured with
the `static` method like above, you must provide the
`options` key). If present, the `options` key must
be a hash of non-empty strings for the keys and the
values.

If the `macaddress` key is provided, then the value
of this key will be put as comment in the file
`/etc/network/interfaces`. Furthermore, a udev rule
will be set in order to ensure that the interface
with the provided macaddress has really the name
stated in the `interfaces` parameter.

The `comment` key must be an non-empty array of non-empty
strings. Each string in this array is a line of comment
just above the interface settings in the file
`/etc/network/interfaces`.

**Remark:** bonding and bridging are allowed.




## Data binding

In the `network::data()` function, there is a lookup
of these keys:

* `inventory_networks`,
* `interfaces`

with the `lookup()` function. **Theses keys must be
found in hiera or in the environment** (via the
`environment::data()` function) because **no default
values are provided**. For these keys, the lookup
uses a hash-merging.

In yaml format (but the format could be a puppet code too
for instance in the `environment::data()` function), the
`inventory_networks` has this form:

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

The value of the `interfaces` key must be a hash with
the same structure as the `interfaces` parameter of the
`::network` class described above except you can add the
optional `in_networks` key and put the `__default__`
value in the `options` hash like this:

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
which must be a non-empty array of non-empty strings. This
key must be present if you use at least one `__default__`
value for this interface in the `options` hash. In this case,
the `__default__` value will replaced by the relevant value
in the `inventory_networks` hash. The **first** network
provided in the array `in_networks` will be used. To be more
precise, with `xxx: '__default__'`, the value will be
replaced by the value of `xxx` in the `inventory_networks`
hash, except if `xxx` is `network`, `netmask` or `broadcast`
where the `cidr_address` of the `inventory_networks` hash
will be used to deduce the right value.

**Remark:** the `__default__` value is interpreted and
replaced **only when present in the `options` hash**.

The `comment` key is a little special. The final value will
not be the value in the `interfaces` key. The `comment`
values will be the result of the lines concatenation between
the `comment` value in the `inventory_networks` and the
`comment` value in the `interfaces`. If no comment are given
in a interface, just the comment in the `inventory_networks`
key will be used (if this interface has the `on_networks`
key of course). If the interface has no `on_networks` key,
just the comment of the interface will be inserted.

In addition of the 2 yaml examples above, if you add too
this entry in hiera:

```yaml
# Not recommended.
network::restart: true
```

then you will have a call completely equivalent to the
call of the class given in the "complex" example in the
"usage" part above with just this line:

```puppet
include '::network'
```

# The `network::ntp` class

## Usage

Here is some examples:

```puppet
# A ntp server which listen on eth0.
# The service synchronize its time to the servers in `ntp_servers`.
# Only hosts in the network 172.31.0.0/16 are able to synchronize
# to the current server.
class { '::ntp'
  interfaces         => [ 'eth0' ],
  ntp_servers        => [ '172.31.5.1', '172.31.5.2', '172.31.5.3' ],
  subnets_authorized => [ '172.31.0.0/16' ],
  ipv6               => false,
}

# A basic ntp server like after a simple `apt-get install ntp`.
class { '::ntp'
  interfaces         => 'all',
  ntp_servers        => [ '172.31.5.1', '172.31.5.2', '172.31.5.3' ],
  subnets_authorized => 'all',
  ipv6               => false,
}
```

The `interfaces` parameter is an array of interface names
used by the ntp service. This parameter can have the
specific value `"all"` (a string) which means that the
ntp service will listen to all interfaces.

The `ntp_servers` parameter is an array of ntp servers
addresses to which the ntp daemon will refer.

The `subnets_authorized` parameter is an array of CIDR
addresses of only subnets authorized to exchange time
with the NTP service. It concerns just the time exchange,
in any case, the configuration will be allowed only from
localhost. Be careful, the hosts listed in the `ntp_servers`
parameter must be within authorized subnets. If not, the
ntp daemon will be just unable to synchronize its time
with the time of the remote ntp servers. The
`subnets_authorized` parameter can have the specific
value `"all"` (a string) which means that any host for
any subnet can exchange time with the ntp service.

The `ipv6` is a boolean. If true, IPv6 is taken into
account by the ntp daemon. If false, ntp will just
use the IPv4 protocol.




## Data binding

The module is linked to the `network` module because it
uses the `::network::get_ntp_servers()` function to
get a default value for the `ntp_servers` parameter
(see below).

The default value of the `interfaces` parameter is `"all"`.

For the `ntp_servers` parameter, the module uses the
`::network::get_ntp_servers()` function and searches the
interfaces of the `interfaces` hiera entry which have the
`in_networks` key. For each of these interfaces, the
function takes its primary network and if the `ntp_servers`
key is present in the `inventory_networks` entry for
this primary network, the function will take its value.
If no ntp servers are found during the research, then the
function returns an array of Debian ntp servers.

The default value of `subnets_authorized` parameter is `"all"`.

The default value of `ipv6` is `false`.




# The `::network::dump_cidr` function

Here is an example:

```puppet
$dump = ::network::dump_cidr('172.31.3.4/20')

# Or (completely equivalent):
$dump = ::network::dump_cidr('172.31.3.4/255.255.240.0')

# After this 2 equivalent calls of the function,
# the value of the $dump variable will be:
{ address     => '172.31.3.4',
  network     => '172.31.0.0',
  broadcast   => '172.31.15.255',
  netmask     => '255.255.240.0',
  cidr        => '172.31.3.4/20',
  netmask_num => '20',
}
```

If the argument of the function is not a valid CIDR
address, the function will raise a `ParseError` exception.

**Remark:** you can use IPv6 addresses too with this function.






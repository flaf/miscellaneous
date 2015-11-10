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
an update of the network configuration. **It is not
recommended to set this parameter to `true`**. With a
basic network configuration (one interface with one IP
address) it will probably work but with a more complicated
network configuration (several interfaces with bridges
etc.), this will certainly fail and you will lose the
network connection.

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




# The `network::resolv_conf` class

This class manages the file `/etc/resolv.conf`.

## Usage

Here is an example:

```puppet
class { '::network::resolv_conf':
  domain         => $::domain,
  search         => $::domain,
  nameservers    => [ '8.8.8.8', '8.8.4.4' ],
  local_resolver => true,
  timeout        => 5,
  override_dhcp  => false,
}
```


## Data binding

The `domain` parameter is a string which sets the `domain`
stanza in the file `/etc/resolv.conf`. The default value
of this parameter is `$::domain`.

The `search` parameter is a non-empty array of non-empty
strings which sets the `search` stanza in the file
`/etc/resolv.conf`. The default value of this parameter is
the value of:

```puppet
$dns_search = ::network::get_param( $interfaces,
                                    $inventory_networks,
                                    'dns_search',
                                    [ $::domain ] )
```

The `nameservers` parameter is a non-empty array of
non-empty strings which sets the `nameserver` stanzas
in the `/etc/resolv.conf`. The default value of this
parameter is the value of:

```puppet
$default_dns = [ '8.8.8.8', '8.8.4.4' ]
$dns_servers = ::network::get_param( $interfaces,
                                     $inventory_networks,
                                     'dns_servers',
                                     $default_dns )
```

The `local_resolver` parameter is a boolean. If true, the
class will install the unbound service which listens on
localhost. unbound will be a DNS forwarder which will forward
all DNS queries to the DNS servers of the `$nameservers`
parameter. In this case, the file `/etc/resolv.conf` will be
updated and the stanza below will be inserted:

```
nameserver 127.0.0.1
```

The `timeout` parameter is an integer which sets the
`timeout:` stanza in the file `/etc/resolv.conf`. Its
default value is `5`.

The `override_dhcp` parameter is a boolean. If an interface
of the host is configured via DHCP, by default the file
`/etc/resolv.conf` is not managed. If this parameter is set
to `true`, the file will be managed even if there is an
interface configured via DHCP.




# The `network::hosts` class

This class manages the file `/etc/hosts`.


## Usage

Here is an example:

```puppet
$address_eth0 = $::facts['networking']['interfaces']['eth0']['bindings'][0]['address']

class { '::network::hosts':
  entries  => {
               '127.0.1.1'         => [ $::fqdn, $::hostname ],
               "@@${address_eth0}" => [ "monitor-1.${::domain}", 'monitor-1' ],
              },
  from_tag => 'ceph-cluster',
}
```

## Data binding

The `entries` parameter is a hash where the keys are
IP addresses and the values are arrays of host names.


In the `entries` parameter, if an address begins with
`@@`, the host entry will be exported with the tag
given by the `from_tag` parameter and the host will
retrieve all the hosts entries from the `from_tag`
tag.

The default values of these two parameters will be retrieved
from the `hosts` entry in hiera or in the `environment.conf`
**if it exists**. Here is an example of `hosts` entry which
matches with the call of the class above:

```yaml
# Here, we use the interpolation token in hiera:
#
#   http://docs.puppetlabs.com/hiera/3.0/variables.html
#
hosts:
  entries:
    '127.0.1.1':
      - '%{::fqdn}'
      - '%{::hostname}'
    '@@%{::facts.networking.interfaces.eth0.bindings.0.address}':
      - 'monitor-1.%{::domain}'
      - 'monitor-1'
  tag: 'ceph-cluster'
```

And here is a typical example of yaml file which could
be shared by several nodes of a unique cluster to share
its "IP eth0-address":

```yaml
# File read be each node of a cluster.
hosts:
  entries:
    '@@%{::facts.networking.interfaces.eth0.bindings.0.address}':
      - '%{::fqdn}'
      - '%{::hostname}'
  tag: 'ceph-cluster'
```

**Warning :** if :
1. the address `127.0.1.1` is not present in the hosts entries,
2. **and** if `$::fqdn` is not present at all in any hosts entries,
3. **and** if `$::hostnme` is not present at all in any hosts entries,
then the entry `{'127.0.1.1' => [$::fqdn, $::hostname]}` is
automatically added in the hosts entries.


If the `hosts` entry doesn't exist in hiera, the default
value of the `entries` parameter will be
`{ '127.0.1.1' => [ $::fqdn, $::hostname ] }`
and the default value of the `from_tag` will be `''` (the
empty string) which means that the host retrieves no
exported hosts entry.

In fact, there are 2 possible kinds of configuration:

* If the host exports no hosts entry (ie there is no address
which begins with `@@`), then the host retrieves hosts
entries from the `entries` parameter **and**, **if** the
value of the `from_tag` parameter is a non-empty string, the
hosts entries exported with the tag equal to the value of
the `from_tag` parameter.

* If the host exports some hosts entries (ie there are
addresses which begin with `@@`), then the `from_tag`
parameter **must** be a non-empty string and the host
retrieves the hosts entries from the `entries` parameter
(with its own exported entries included) and the hosts
entries exported with the tag equal to the value of
the `from_tag` parameter.




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
{
  address     => '172.31.3.4',
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




# The `::network::get_param()` function

Here is an example:

```puppet
$dns_servers = ::network::get_param( $interfaces,
                                     $inventory_networks,
                                     'dns_servers',
                                     $default )
```

The `$interfaces` and `$inventory_networks` arguments are
hashes with the structure described above. The function
creates an array A of interfaces among `$interfaces` where
each interface has a primary network and where the
`'dns_servers'` key is defined in this primary network. If
the array A is empty, the function returns `$default`, else
the function returns the value of the `'dns_servers'` key in
the primary network of the first interface of the array A.

**Simple and usual case :** if the host has just only one
interface in a only one network N, the function will return
the value of the `'dns_servers'` key in the network N if
this key exists, else the function will return `$default`.




# TODO

* Finish to add the "routes" feature.





# Module description

This module implements a configuration of the
`/etc/network/interfaces` file and some others
basic network configurations.

All the parameters of this module are in the class
`network::params`.




# The `network` class

## Usage

Here is some examples with this yaml configuration:

```yaml
network::params::inventory_networks:
  admin_mgt:
    comment: [ 'Network dedicated to management.' ]
    vlan_id: '1000'
    vlan_name: 'admin_mgt'
    cidr_address: '172.31.0.0/16'
    gateway: '172.31.0.1'
    dns_servers: [ '172.31.10.1', '172.31.10.2' ]
    ntp_servers: [ '172.31.11.1', '172.31.11.2', '172.31.11.3' ]
    routes:
      mgt2mysql: { 'to': '192.168.1.0/24', 'via': '172.31.0.2' }
      mgt2puppet: { 'to': '195.221.97.17/32', 'via': '172.31.0.50' }
  mysql:
    comment: [ 'Network dedicated to MySQL.' ]
    vlan_id: '1001'
    vlan_name: 'mysql'
    cidr_address: '192.168.1.0/24'
```

### A basic example

With this yaml code:

```yaml
network::params::restart: true

network::params::ifaces:
  eth0:
    in_networks: [ 'admin_mgt' ]
    macaddress: '00:1c:cf:50:0b:52'
    comment: [ 'This is the management interface.' ]
    inet:
      method: 'dhcp'
```

and this simple puppet code `include '::network'`.


### A more complex example

With this yaml code:

```yaml
network::params::restart: false # currently the default value

network::params::ifaces:
  eth0:
    in_networks: [ 'mysql' ]
    macaddress: '00:1c:cf:50:0b:51'
    comment: [ 'This is the MySQL interface.' ]
    inet:
      method: 'static'
      options:
        address: '192.168.1.123'
        network: '__default__'   # <= will be automatically completed via inventory_networks
        netmask: '__default__'   # <=
        broadcast: '__default__' # <=
  eth1:
    in_networks: [ 'admin_mgt' ]
    routes: [ 'mgt2mysql', 'mgt2puppet' ]
    macaddress: '00:1c:cf:50:0b:52'
    comment: [ 'This is the management interface.' ]
    inet:
      method: 'static'
      options:
        address: '172.31.0.123'
        network: '__default__'   # <= will be automatically completed via inventory_networks
        netmask: '__default__'   # <=
        broadcast: '__default__' # <=
        gateway: '__default__'   # <=
        post-up_puppet_suffix_a: 'echo 1 > /proc/sys/net/ipv4/ip_forward'
        post-up_puppet_suffix_b: '/usr/local/sbin/iptables.sh up'
        post-down: '/usr/local/sbin/iptables.sh down'
```

and this simple puppet code `include '::network'`.


### Few explanations

**Warning:** the file `/etc/network/interfaces` is not
managed at all by this class, unless the parameter
`network::params::restart` is set to `true` (not
recommended, see below). If set to `false` (the default),
the file managed by the class is just
`/etc/network/interfaces.puppet` and you should restart the
network manually.

The `restart` parameter is a boolean. If the value
is `true`, then the network will be restarted after
an update of the network configuration. **It is not
recommended to set this parameter to `true`**. With a
basic network configuration (one interface with one IP
address) it will probably work but with a more complicated
network configuration (several interfaces with bridges
etc.), this will certainly fail and you will lose the
network connection.

In the `ifaces` parameter, for each interface,
you can put:

* a `inet` configuration (for IPv4)
* and/or a `inet6` configuration (for IPv6),
* a `macaddress` key mapped to a non-empty string (optional),
* a `comment` key mapped to a non-empty array of
non-empty strings (optional),

The `inet` and `inet6` keys are optional. If neither `inet`
nor `inet6` are present, there will be no configuration at
all in `/etc/network/interfaces.puppet` concerning the
interface, but:

* comments concerning this interface will be put in
`/etc/network/interfaces.puppet` if the `comment` key is provided
* and a udev rule concerning the name of this interface
will be applied if the `macaddress` key is provided.

In each interface, if at least a `inet` key or a `inet6`
exists, the mapped value must be a hash. In each `inet` and
`inet6` hash, you can put:

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




## Parameters of `network::params`

There is no default value for these parameters :

* `network::params::inventory_networks`
* `network::params::ifaces`

**The values of theses parameters must provided explicitely
by the user** (for instance via hiera or directly in puppet
code). For the `inventory_networks` parameter, the default
merging policy is `deep`. In yaml format (but the format
could be a puppet code too), the `inventory_networks` has
the form showed above in the usage section.

`inventory_networks` is a hash where each key must be a
string, a name of a network, and each value must be a hash.
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

The `routes` entry above is optional but, if present, it
must have the same structure as in the example above. This
entry can be used to add easily routes in the
`/etc/network/interfaces` file (see below).

In the `ifaces` parameter, the `__default__` value is
special because it will be replaced automatically by the
correct value via the `inventory_network` parameter **if**
the interface has the `in_networks` sub-key present. Indeed,
the `in_networks` key is optional for a given interface
which must be a non-empty array of non-empty strings. This
key must be present if you use at least one `__default__`
value for this interface in the `options` hash. In this
case, the `__default__` value will be replaced by the
relevant value in the `inventory_networks` hash. The
**first** network provided in the array `in_networks` will
be used. To be more precise, with `xxx: '__default__'`, the
value will be replaced by the value of `xxx` in the
`inventory_networks` hash, except if `xxx` is `network`,
`netmask` or `broadcast` where the `cidr_address` of the
`inventory_networks` hash will be used to deduce the right
value.

**Remark:** the `__default__` value is interpreted and
replaced **only when present in the `options` hash**.

The `comment` key is a little special. The final value will
not be the value in the `ifaces` parameter. The `comment`
values will be the result of the lines concatenation between
the `comment` value in the `inventory_networks` and the
`comment` value in the `ifaces`. If no comment are given
in a interface, just the comment in the `inventory_networks`
key will be used (if this interface has the `on_networks`
key of course). If the interface has no `on_networks` key,
just the comment of the interface will be inserted.

**The `routes` entry above is special**. It allows to add
automatically routes in the `/etc/network/interfaces`
with `pre-down` and `post-up` instructions. This entry
must be an array of non-empty strings which *must* be the
names of routes defined in the networks mentioned in the
`in_networks` array.

**In the options, the keys with this form
`foo_puppet_suffix_bar` are special**. In this case, all the
part `/_puppet_suffix_.*$/` is removed and only the
remaining text is put in the `interfaces` file. For instance
`post-up_puppet_suffix_a: 'cmd1'` in the yaml file will just
become `post-up cmd1` in the `interfaces` file. The goal is
to be able to put several times the same option (the typical
example is the `post-up` option) which is normally
impossible in a yaml file where each key must be unique.

**Note:** the class `network::params` has another parameter
called `interfaces`. This parameter has exactly the same
value as the `ifaces` parameter except that the strings
`__default__` have been replaced by their relevant values.
In fact, in this module, the parameter `ifaces` is not
really used and `interfaces` is used instead. So if you
want to retrieve the real interfaces configuration of a
node in a puppet code, you have to use the `interfaces`
parameter :

```puppet
include '::network'

# Better than $::network::params::ifaces because it doesn't
# contain the '__default__' strings which have been
# replaced.
$interfaces = $::network::params::interfaces
```




# The `network::resolv_conf` class

This class manages the file `/etc/resolv.conf`.

## Usage

Here is an example. We assume that the parameters
`inventory_networks` and `ifaces` (and necessarily the
parameter `interfaces`) are already defined for instance via
hiera:

```puppet
class { '::network::resolv_conf::params':
  domain                        => $::domain,
  search                        => [ $::domain ],
  timeout                       => 5,
  override_dhcp                 => false,
  dns_servers                   => [ '8.8.8.8', '8.8.4.4' ],
  local_resolver                => true,
  local_resolver_interface      => [ '127.0.0.1', '172.31.0.5' ],
  local_resolver_access_control => [
                                    [ '172.17.0.0/24', 'allow' ],
                                    [ '172.18.0.0/24', 'deny' ],
                                   ],
}

include '::network::resolv_conf'
```


## Parameters of `network::resolv_conf::params`

The `domain` parameter is a string which sets the
`domain` stanza in the file `/etc/resolv.conf`. The default
value of this parameter is `$::domain`.

The `search` parameter is a non-empty array of
non-empty strings which sets the `search` stanza in the file
`/etc/resolv.conf`. The default value of this parameter is:

```puppet
# See below for explanations concerning the function network::get_param().
$dns_search = ::network::get_param( $::network::params::interfaces,
                                    $::network::params::inventory_networks,
                                    'dns_search',
                                    [ $::domain ] )
```

The `timeout` parameter is an integer which sets
the `timeout:` stanza in the file `/etc/resolv.conf`. Its
default value is `5`.

The `override_dhcp` parameter is a boolean. If at
least one interface of the host is configured via DHCP, by
default the file `/etc/resolv.conf` is automatically not
managed. If this parameter is set to `true`, the file will
be managed even if there is an interface configured via
DHCP. The default value of this parameter is `false`.

The `dns_servers` parameter is a non-empty array of
non-empty strings which sets the `nameserver` stanzas in the
`/etc/resolv.conf` **or** the DNS forwarders of the resolver
if a local resolver is installed (see below). The default
value of this parameter is:

```puppet
# So undef is a possible default value. This is allowed if
# the file /etc/resolv.conf is not managed (typically in a
# DHCP configuration). If not, the default undef value can
# raise an error.
$dns_servers = ::network::get_param( $::network::params::interfaces,
                                     $::network::params::inventory_networks,
                                     'dns_servers')
```

The `local_resolver` parameter is a boolean. If true (its
default value), the class will install the unbound service
which listens on localhost. unbound will be a DNS forwarder
which will forward all DNS queries to the DNS servers of the
`$dns_servers` parameter. In this case, the file
`/etc/resolv.conf` will be updated and the stanza below will
be inserted:

```
nameserver 127.0.0.1
```

The parameters `local_resolver_interface` and
`local_resolver_access_control` represent the options
`interface` and `access-control` of the local resolver
unbound (see the manual unbound.conf(5) for more details).
If `local_resolver` is set to `false`, these parameters are
completely ignored. The default value of these parameters is
`[]` (ie an empty array). In this case, no option
`interface` is present in the unbound configuration (ie
unbound just listens to 127.0.0.1) and no option
`access-control` is present too.

**Remark :** if `local_resolver_interface` isn't equal to
`[]` (its default value) and if it doesn't contain
`'127.0.0.1'`, then `'127.0.0.1'` will be automatically
appended (so that the host is always able to use the unbound
service via locahost).




# The `network::hosts` class

This class manages the file `/etc/hosts`.


## Usage

Here is an example:

```puppet
$address_eth0 = $::facts['networking']['interfaces']['eth0']['bindings'][0]['address']

class { '::network::hosts::params':
  entries        => {
                     '127.0.1.1'         => [ $::fqdn, $::hostname ],
                     "@@${address_eth0}" => [ "monitor-1.${::domain}", 'monitor-1' ],
                    },
  hosts_from_tag => 'ceph-cluster',
}

include '::network::hosts'
```


## Parameters of `network::hosts::params`

The `entries` parameter is a hash where the keys are
IP addresses and the values are arrays of host names.
The default value of this parameter is `{}` ie no
hosts entry. Warning, the default merging policy
concerning this parameter `entries` is `deep`.

In fact, if not present, this "default" entry:

```puppet
'127.0.1.1' => [ $::fqdn, $::hostname ]
```

is automatically added. Like `ifaces` and `interfaces` for
the `network` class, the `network::hosts::params` has the
`entries` parameter and the `entries_completed` parameters
where `entries_completed` is completed from `entries`with
the "default" entry `127.0.1.1` above if not present.

**Warning :** more precisely if :
1. the address `127.0.1.1` is not present in the hosts entries,
2. **and** if `$::fqdn` is not present at all in any hosts entries,
3. **and** if `$::hostname` is not present at all in any hosts entries,
then the entry `'127.0.1.1' => [$::fqdn, $::hostname]` is
automatically added in the hosts entries (ie in the `hosts_entries`
parameter).

In the `entries` parameter, if at least one IP address begins
with `@@`, the host entry will be exported with the tag
given by the `hosts_from_tag` parameter and the host will
retrieve all the hosts entries from the `hosts_from_tag`
tag.

Here is an example of `entries` parameter set via hiera:

```yaml
# Here, we use the interpolation token in hiera:
#
#   http://docs.puppetlabs.com/hiera/3.0/variables.html
#
network::hosts::params::entries:
  '127.0.1.1':
    - '%{::fqdn}'
    - '%{::hostname}'
  '@@%{::facts.networking.interfaces.eth0.bindings.0.address}':
    - 'monitor-1.%{::domain}'
    - 'monitor-1'
network::hosts::params::hosts_from_tag: 'ceph-cluster'
```

And here is a typical example of yaml file which could
be shared by several nodes of a unique cluster to share
its "IP eth0-address":

```yaml
# File read be each node of a cluster.
network::hosts::params::entries:
  '@@%{::facts.networking.interfaces.eth0.bindings.0.address}':
    - '%{::fqdn}'
    - '%{::hostname}'
network::hosts::params::hosts_from_tag: 'ceph-cluster'
```

The default value of the `hosts_from_tag` parameter is `''`
(the empty string) which means that the host retrieves no
exported hosts entry.

In fact, there are 2 possible kinds of configuration:

* If the host exports no hosts entry (ie there is no address
which begins with `@@`), then the host retrieves hosts
entries from the `entries` parameter **and**, **if** the value
of the `hosts_from_tag` parameter is a non-empty string, the
hosts entries will be exported with the tag equal to the value of
the `from_tag` parameter.

* If the host exports some hosts entries (ie there are
addresses which begin with `@@`), then the `hosts_from_tag`
parameter **must** be set to a non-empty string and the host
retrieves the hosts entries from the `entries` parameter (with
its own exported entries included) and the hosts entries
exported with the tag equal to the value of the
`hosts_from_tag` parameter.




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
# Here, we set a default value if 'dns_servers' is not found
# in "inventory_networks".
$dns_servers = ::network::get_param( $::network::params::interfaces,
                                     $::network::params::inventory_networks,
                                     'dns_servers',
                                     $default )

# Here, no default value. If 'dns_servers' is not found in
# "inventory_networks", this instruction becomes equivalent
# to:
#
#    $dns_servers = undef
#
$dns_servers = ::network::get_param( $::network::params::interfaces,
                                     $::network::params::inventory_networks,
                                     'dns_servers')
```

The `$::network::params::interfaces` and
`$::network::params::inventory_networks` arguments are
hashes with the structure described above. The function
creates an array A of interfaces among
`$::network::interfaces` where each interface has a primary
network and where the `'dns_servers'` key is defined in this
primary network. If the array A is empty, the function
returns `$default` or `undef` if there is no "default"
argument, else the function returns the value of the
`'dns_servers'` key in the primary network of:

- the first interface of the array A which has an IP address,
- or just the first interface of the array A if there is no
interface with an address.

**Simple and usual case :** if the host has just only one
interface in a only one network N, the function will return
the value of the `'dns_servers'` key in the network N if
this key exists, else the function will return `$default`
(or `undef` in the second example).




# The `::network::has_address()` function

Here is an example:

```puppet
$boolean = ::network::has_address($::network::params::interfaces, 'eth1')
```

The `$::network::params::interfaces` argument is a hash with
the structure described above. The function fails if `eth1`
is not present in the hash `$interfaces`. If present, the
function returns `true` if the interface `eth1` has an IP
address (ie has a `static` or `dhcp` method in its inet or
inet6 configuration), else the function returns `false`.




# The `::network::get_addresses()` function

Here is an example:

```puppet
$my_addresses = ::network::get_addresses($::network::params::interfaces)
```

The `$::network::params::interfaces` argument is a hash with
the structure described above. The function returns an array
with all the addresses explicitly defined in the variable
`$::network::params::interfaces`, ie when an interface has a
`static` method with the `address` options. For instance, if
`$::network::params::interfaces` has just one interface
`eth0` defined with the `dhcp` method, the function will
just return an empty array.




# TODO

* Allow and support the case where the value of an option key
is an array of non empty-strings. For instance, it could be
cool to allow in hiera something like:
```yaml
options:
  post-up: [ 'cmd1...', 'cmd2...' ]
```



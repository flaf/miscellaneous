# Module description

Module to install a basic installation of a ntp server.

Remark: this module implements the "params" design pattern.




# Usage

Here is some examples:

```puppet
#
# Example 1
#

# A ntp server which listen on eth0.
# The service synchronize its time to the servers in `ntp_servers`.
# Only hosts in the network 172.31.0.0/16 are able to synchronize
# to the current server.
class { '::basic_ntp::params'
  interfaces         => [ 'eth0' ],
  servers            => [ '172.31.5.1', '172.31.5.2', '172.31.5.3' ],
  subnets_authorized => [ '172.31.0.0/16' ],
  ipv6               => false,
}

include '::basic_ntp'


#
# Example 2
#

# A basic ntp server like after a simple `apt-get install ntp`.
class { '::basic_ntp::params'
  interfaces         => 'all',
  servers            => [ '172.31.5.1', '172.31.5.2', '172.31.5.3' ],
  subnets_authorized => 'all',
  ipv6               => false,
}

include '::basic_ntp'
```




# Parameters

The `interfaces` parameter is an array of interface names
used by the ntp service. This parameter can have the
specific value `'all'` (a string) which means that the ntp
service will listen to all interfaces. The default value
of this parameter is `'all'`.

The `servers` parameter is an array of ntp servers addresses
to which the ntp daemon will refer. For the `servers`
parameter, its default value is the value of the `$servers`
variable below:

```puppet
$default_ntp = [
                '0.debian.pool.ntp.org',
                '1.debian.pool.ntp.org',
                '2.debian.pool.ntp.org',
                '3.debian.pool.ntp.org',
               ]

include '::network::params'
$interfaces         = $::network::params::interfaces
$inventory_networks = $::network::params::inventory_networks

$servers = ::network::get_param( $interfaces, $inventory_networks,
                                 'ntp_servers', $default_ntp )
```

The `subnets_authorized` parameter is an array of CIDR
addresses of only subnets authorized to exchange time with
the NTP service. It concerns just the time exchange, in any
case, the configuration will be allowed only from localhost.
Be careful, the hosts listed in the `servers` parameter must
be within authorized subnets. If not, the ntp daemon will be
just unable to synchronize its time with the time of the
remote ntp servers. The `subnets_authorized` parameter can
have the specific value `'all'` (a string) which means that
any host for any subnet can exchange time with the ntp
service. The default value of the `subnets_authorized`
parameter is `'all'`.

The `ipv6` parameter is a boolean. If true, IPv6 is taken
into account by the ntp daemon. If false, ntp will just use
the IPv4 protocol. The default value of the `ipv6` parameter
is `false`.





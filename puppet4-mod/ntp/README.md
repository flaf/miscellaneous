# Module description

This module implements a configuration of the `ntp` service.




# Usage

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

# A basic and selfish (none server can synchronize to it) ntp server.
class { '::ntp'
  interfaces         => 'all',
  ntp_servers        => [ '172.31.5.1', '172.31.5.2', '172.31.5.3' ],
  subnets_authorized => [],
  ipv6               => false,
}
```

The `interfaces` parameter is an array of interface names
used by the ntp service. This parameter can have the
specific value `"all"` (a string) which means that the
ntp service will listen to all interfaces.

The `ntp_servers` parameter is an array of ntp servers
addresses.

The `subnets_authorized` parameter is an array of CIDR
addresses of only subnets authorized to exchange time
with the NTP service (except the servers listed in the
`ntp_servers` of course). If this parameter is `[]`
(ie an empty array) none host can exchange time with
the ntp service (ie it's a selfish ntp server). This
parameter can have the specific value `"all"` (a string)
which means that any host for any subnet can exchange
time with the ntp service.

The `ipv6` is a boolean. If true, IPv6 is taken into
account in the `/etc/ntp.conf` file. If false, just
IPv4 stanza are used in this file.




# Data binding

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

The default value of `subnets_authorized` parameter is
`[]` (ie an empty array) so that it will be a selfish ntp
server.

The default value of `ipv6` is `false`.



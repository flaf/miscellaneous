# Module description

This module just installs and manages a little PXE/DHCP server
(not DNS service is installed).

# Usage

Here is an example:

```puppet
class { '::pxeserver':
  dhcp_range              => [ '172.31.0.200', '172.31.0.250' ],
  dhcp_dns_servers        => [ '172.31.0.5', '172.31.0.6' ],
  dhcp_gateway            => '172.31.0.1',
  ip_reservations         => {
                              '20:cf:30:52:6a:56' => [ '172.31.100.1', 'srv-1' ],
                              '20:cf:30:52:6a:57' => [ '172.31.100.2', 'srv-2' ],
                             },
  puppet_collection       => 'PC1',
  pinning_puppet_version  => '1.3.0-*',
  puppet_server           => 'puppet.domain.tld',
  puppet_ca_server        => 'puppet.domain.tld',
}
```

# Warning

With this module, the host will have a DHCP service and
a TFTP service (to provide boot PXE) but no DNS service
is installed.

This module should be used only with hosts which have
just only **one interface** (or two interfaces if you take
into account `lo` of course). Outside of this condition,
there is no warranty that the module works well.


# Data binding

The `dhcp_range` parameter is mandatory.
The `ip_reservations` parameter is optional and its default
value is `{}` (a empty hash), ie no IP reservation.

The other parameters are optional and the module will try to
get smart default values from the data binding mechanism
from other modules.

* The default value of `dhcp_dns_servers` and `dhcp_gateway`
are retrieved from the data binding mechanism of the
`flaf-network` module.

* The default value of `puppet_collection` and `pinning_puppet_version`
are retrieved from the data binding mechanism of the
`flaf-repository` module.

* The default value of `puppet_server` and `puppet_ca_server`
are retrieved from the data binding mechanism of the
`flaf-puppetagent` module.

See the code of `./function/data.pp` for more details.



function pxeserver::data {

  $puppet_collection      = lookup('repository::puppet::collection',
                                   String[1], 'first', 'NOT-DEFINED')
  $pinning_puppet_version = lookup('repository::puppet::pinning_agent_version',
                                   String[1], 'first', 'NOT-DEFINED')
  $puppet_server          = lookup('puppetagent::server',
                                   String[1], 'first', 'NOT-DEFINED')
  $puppet_ca_server       = lookup('puppetagent::ca_server',
                                   String[1], 'first', 'NOT-DEFINED')

  $dhcp_dns_servers  = lookup('network::resolv_conf::nameservers',
                             Array, 'first', [])

  $interfaces        = lookup('network::interfaces', Hash, 'first', {})

  $primary_iface     = $facts['networking']['primary']

  if $interfaces.has_key($primary_iface)
  and $interfaces[$primary_iface].has_key('inet')
  and $interfaces[$primary_iface]['inet'].has_key('options')
  and $interfaces[$primary_iface]['inet']['options'].has_key('gateway') {
    $dhcp_gateway = $interfaces[$primary_iface]['inet']['options']['gateway']
  } else {
    $dhcp_gateway = 'NOT-DEFINED'
  };

  {
    pxeserver::dhcp_range              => [ 'NOT-DEFINED', 'NOT-DEFINED' ],
    pxeserver::dhcp_dns_servers        => $dhcp_dns_servers,
    pxeserver::dhcp_gateway            => $dhcp_gateway,
    pxeserver::ip_reservations         => {},
    pxeserver::puppet_collection       => $puppet_collection,
    pxeserver::pinning_puppet_version  => $pinning_puppet_version,
    pxeserver::puppet_server           => $puppet_server,
    pxeserver::puppet_ca_server        => $puppet_ca_server,
    pxeserver::supported_distributions => [ 'trusty' ],
  }

}



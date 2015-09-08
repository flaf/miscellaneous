function network::data {

$inventory_networks = lookup('inventory_networks', Hash[String[1], Data, 1], 'hash')
$interfaces         = lookup('interfaces', Hash[String[1], Data, 1], 'hash')
$interfaces_filled  = ::network::fill_interfaces($interfaces, $inventory_networks);

  { network::restart                 => false,
    network::interfaces              => $interfaces_filled,
    network::supported_distributions => [ 'trusty', 'jessie' ],
    network::stage                   => 'network',
  }

}



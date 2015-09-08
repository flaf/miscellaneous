function network::get_interfaces {

  $inventory_networks = ::network::get_inventory_networks()
  $interfaces         = lookup('interfaces', Hash[String[1], Data, 1], 'hash');

  ::network::fill_interfaces($interfaces, $inventory_networks)

}



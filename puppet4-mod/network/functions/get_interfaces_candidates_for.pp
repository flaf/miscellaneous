function network::get_interfaces_candidates_for (String[1] $param) {

  $inventory_networks = ::network::get_inventory_networks()
  $interfaces         = ::network::get_interfaces()

  # Create an array of interface names among $interfaces
  # for each interface in a network where $param
  # key is defined.
  $ifaces_candidates  = $interfaces.keys.sort.filter |$iface| {
    if $interfaces[$iface].has_key($param) {
      $network_candidate = $interfaces[$iface][$param][0];
      $inventory_networks[$network_candidate].has_key($param)
    }
    else {
      false
    }
  };

  $ifaces_candidates

}



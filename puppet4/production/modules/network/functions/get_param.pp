function network::get_param (
  Hash[String[1], Hash[String[1], Data, 1], 1] $interfaces,
  Hash[String[1], Data, 1]                     $inventory_networks,
  String[1]                                    $param,
  Data                                         $default,
) {

  # Create an array of interface names among $interfaces
  # where each interface has a primary network and where
  # $param key is defined in this primary network.
  $ifaces_candidates  = $interfaces.keys.sort.filter |$iface| {
    if $interfaces[$iface].has_key('in_networks') {
      $primary_network = $interfaces[$iface]['in_networks'][0];
      $inventory_networks[$primary_network].has_key($param)
    }
    else {
      false
    }
  }

  if $ifaces_candidates.empty {
    $result = $default
  } else {
    # We take the value of $param in the primary network of the first
    # candidate interface.
    $network_param = $interfaces[$ifaces_candidates[0]]['in_networks'][0]
    $result        = $inventory_networks[$network_param][$param]
  };

  $result

}



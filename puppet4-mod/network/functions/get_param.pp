function network::get_param (
  Hash[String[1], Hash[String[1], Data, 1], 1] $interfaces,
  Hash[String[1], Data, 1]                     $inventory_networks,
  String[1]                                    $param,
  Data                                         $default,
) {

  # Create an array of interface names among $interfaces
  # for each interface in a network where $param
  # key is defined.
  $ifaces_candidates  = $interfaces.keys.sort.filter |$iface| {
    if $interfaces[$iface].has_key('in_networks') {
      $network_candidate = $interfaces[$iface]['in_networks'][0];
      $inventory_networks[$network_candidate].has_key($param)
    }
    else {
      false
    }
  }

  if $ifaces_candidates.empty {
    $result = $default
  } else {
    $network_param = $interfaces[$ifaces_candidates[0]]['in_networks'][0]
    $result        = $inventory_networks[$network_param][$param]
  };

  $result

}



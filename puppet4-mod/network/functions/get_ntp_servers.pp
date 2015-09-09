function network::get_ntp_servers {

  $default_ntp_servers = [ '0.debian.pool.ntp.org',
                           '1.debian.pool.ntp.org',
                           '2.debian.pool.ntp.org',
                           '3.debian.pool.ntp.org',
                         ]
  $inventory_networks  = ::network::get_inventory_networks()
  $interfaces          = ::network::get_interfaces()

  # Create an array of interface names among $interfaces
  # for each interface in a network where 'ntp_servers'
  # key is defined.
  $ifaces_candidates  = $interfaces.keys.sort.filter |$iface| {
    if $interfaces[$iface].has_key('in_networks') {
      $network_candidate = $interfaces[$iface]['in_networks'][0];
      $inventory_networks[$network_candidate].has_key('ntp_servers')
    }
    else {
      false
    }
  }

  if $ifaces_candidates.empty {
    # No interface found, so no ntp servers.
    $ntp_servers = $default_ntp_servers
  } else {
    # We take the first interface among the interfaces candidates
    # and, on this interface, we take the ntp servers of the
    # first network.
    $network_candidate = $interfaces[$ifaces_candidates[0]]['in_networks'][0]
    $ntp_servers       = $inventory_networks[$network_candidate]['ntp_servers']
  };

  $ntp_servers

}



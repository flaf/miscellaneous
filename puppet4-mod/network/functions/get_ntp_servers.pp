function network::get_ntp_servers {

  $default_ntp_servers = [ '0.debian.pool.ntp.org',
                           '1.debian.pool.ntp.org',
                           '2.debian.pool.ntp.org',
                           '3.debian.pool.ntp.org',
                         ]
  $inventory_networks  = ::network::get_inventory_networks()
  $interfaces          = ::network::get_interfaces()
  $ifaces_candidates   = ::network::get_interfaces_candidates_for('ntp_servers')

  if $ifaces_candidates.empty {
    # No interface found, so no ntp servers.
    $ntp_servers = $default_ntp_servers
  } else {
    # We take the first interface among the interfaces candidates
    # and, on this interface, we take the ntp servers of the
    # first network.
    $network_candidate = $interfaces[$ifaces_candidates[0]]['in_networks'][0]
    $ntp_servers       = $inventory_networks[$network_candidate]['ntp_servers']
  }

  unless $ntp_servers =~ Array[String[1], 1] {
    fail(regsubst(@(END), '\n', ' ', 'G'))
      Sorry, the `ntp_servers` key in the inventory networks
      must be a non-empty array of non-empty strings.
      |- END
  };

  $ntp_servers

}



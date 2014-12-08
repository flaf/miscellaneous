class profiles::ntp::standard {

  $inventoried_networks = hiera_hash('inventoried_networks')
  $network_name         = get_network_name($ipaddress, $netmask,
                                           $inventoried_networks)
  $ntp_servers          = $inventoried_networks[$network_name]['ntp_servers']

  if $ntp_servers == undef {
    fail("Problem in class ${title}, `ntp_servers` data not retrieved")
  }

  class { '::ntp':
    ntp_servers =>$ntp_servers,
  }

}



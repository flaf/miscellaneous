class profiles::network::standard ($stage = 'network', ) {

  $inventoried_networks = hiera_hash('inventoried_networks')
  $network_conf         = hiera_hash('network')

  $interfaces           = $network_conf['interfaces']
  $rename_interfaces    = $network_conf['rename_interfaces']
  $restart_network      = $network_conf['restart_network']

  # Test if the data has been well retrieved.
  if $interfaces == undef {
    fail("Problem in class ${title}, `interfaces` data not retrieved")
  }
  if $rename_interfaces == undef {
    fail("Problem in class ${title}, `rename_interfaces` data not retrieved")
  }
  if $restart_network == undef {
    fail("Problem in class ${title}, `restart_network` data not retrieved")
  }

  $interfaces_updated = complete_ifaces_hash($interfaces,
                                             $inventoried_networks)

  class { '::network::interfaces':
    rename_interfaces => $rename_interfaces,
    restart_network   => $restart_network,
    interfaces        => $interfaces_updated,
  }

}



class profiles::network::standard {

  $inventoried_networks = hiera_hash('networks')
  $network_conf         = hiera_hash('network')
  $interfaces           = $network_conf['interfaces']
  $rename_interfaces    = $network_conf['rename_interfaces']
  $restart_network      = $network_conf['restart_network']
  $hosts_entries        = $network_conf['hosts_entries']

  class { '::network::interfaces':
    rename_interfaces    => $rename_interfaces,
    restart_network      => $restart_network,
    inventoried_networks => $inventoried_networks,
    interfaces           => $interfaces,
    before               => Class['::network::hosts'],
  }

  class { '::network::hosts':
    hosts_entries => $hosts_entries,
  }

}



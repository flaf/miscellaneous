class profiles::network::standard {

  $rename_interfaces    = hiera('rename_interfaces')
  $restart_network      = hiera('restart_network')
  $inventoried_networks = hiera_hash('networks')
  $interfaces           = hiera_hash('interfaces')
  $hosts_entries        = hiera_array('hosts_entries', [])

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



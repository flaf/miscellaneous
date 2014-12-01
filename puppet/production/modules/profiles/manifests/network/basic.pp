class profiles::network::basic {

  $rename_interfaces    = hiera('rename_interfaces')
  $restart_network      = hiera('restart_network')
  $inventoried_networks = hiera_hash('networks')
  $interfaces           = hiera_hash('interfaces')

  class { '::network::interfaces':
    rename_interfaces    => $rename_interfaces,
    restart_network      => $restart_network,
    inventoried_networks => $inventoried_networks,
    interfaces           => $interfaces,
    before               => Class['::network::hosts'],
  }

  include '::network::hosts'

}



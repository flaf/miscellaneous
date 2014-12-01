class profiles::network::basic {

  $interfaces           = hiera_hash('interfaces')
  $inventoried_networks = hiera_hash('networks')

  class { '::network::interfaces':
    interfaces           => $interfaces,
    force_ifnames        => true,  # It's a moot point.
    restart_network      => false, # More secure.
    inventoried_networks => $inventoried_networks,
    before               => Class['::network::hosts'],
  }

  include '::network::hosts'

}



class profiles::network::basic {

  $interfaces = hiera_hash('interfaces')

  class { '::network::interfaces':
    interfaces      => $interfaces,
    force_ifnames   => true,  # It's a moot point.
    restart_network => false, # More secure.
    before          => Class['::network::hosts'],
  }

  include '::network::hosts'

}


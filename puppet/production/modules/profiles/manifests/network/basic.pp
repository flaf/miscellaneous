class profiles::network::basic {

  $interfaces = hiera_hash('interfaces')

  class { '::network::interfaces':
    interfaces      => $interfaces,
    force_ifnames   => true, # It's a moot point.
    restart_network => true, # It's a moot point.
    before          => Class['::network::hosts'],
  }

  include '::network::hosts'

}


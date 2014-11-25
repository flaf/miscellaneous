class profiles::network {

  $interfaces = hiera_hash('interfaces')

  class { '::network::interfaces':
    interfaces      => $interfaces,
    restart_network => true,
    before          => Class['::network::hosts'],
  }

  include '::network::hosts'

}


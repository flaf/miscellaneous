class profiles::network {

  $interfaces = hiera_hash('interfaces')

  class { '::network::interfaces':
    interfaces => $interfaces,
  }

}


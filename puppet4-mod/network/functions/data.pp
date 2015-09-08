function network::data {

$interfaces = ::network::get_interfaces();

  { network::restart                 => false,
    network::interfaces              => $interfaces,
    network::supported_distributions => [ 'trusty', 'jessie' ],
    network::stage                   => 'network',
  }

}



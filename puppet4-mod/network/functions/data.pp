function network::data {

$interfaces = ::network::get_interfaces();

  { network::restart                 => false,
    network::interfaces              => $interfaces,
    network::supported_distributions => [ 'trusty', 'jessie' ],
    network::stage                   => 'network',

    network::resolv_conf::domain      => $::domain,
    network::resolv_conf::search      => $::domain,
    network::resolv_conf::nameservers => [ '8.8.8.8', '8.8.4.4' ],
    network::resolv_conf::timeout     => 5,
  }

}



function network::data {

  { network::restart                 => false,
    network::interfaces              => { eth0 => { method => 'dhcp', }, },
    network::supported_distributions => [ 'trusty', 'jessie' ],
  }

}



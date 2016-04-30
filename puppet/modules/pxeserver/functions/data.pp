function pxeserver::data {

  {
    pxeserver::params::dhcp_conf               => undef,
    pxeserver::params::ip_reservations         => {},
    pxeserver::params::puppet_collection       => undef,
    pxeserver::params::pinning_puppet_version  => undef,
    pxeserver::params::puppet_server           => undef,
    pxeserver::params::puppet_ca_server        => undef,
    pxeserver::params::supported_distributions => [ 'trusty' ],
  }

}



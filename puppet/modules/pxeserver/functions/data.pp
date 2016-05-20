function pxeserver::data {

  {
    pxeserver::params::dhcp_confs              => undef,
    pxeserver::params::no_dhcp_interfaces      => [],
    pxeserver::params::apt_proxy               => '',
    pxeserver::params::ip_reservations         => {},
    pxeserver::params::host_records            => {},
    pxeserver::params::backend_dns             => [],
    pxeserver::params::puppet_collection       => undef,
    pxeserver::params::pinning_puppet_version  => undef,
    pxeserver::params::puppet_server           => undef,
    pxeserver::params::puppet_ca_server        => undef,
    pxeserver::params::puppet_apt_url          => undef,
    pxeserver::params::puppet_apt_key          => undef,
    pxeserver::params::supported_distributions => [ 'trusty' ],

    # Merging policy.
    lookup_options => {
      pxeserver::params::host_records => { merge => 'deep', },
    },
  }

}



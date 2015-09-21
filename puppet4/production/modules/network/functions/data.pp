function network::data {

  # Data lookup in hiera or in the environment.conf.
  $inventory_networks = lookup('inventory_networks', Hash[String[1], Data, 1],
                               'hash')
  $ifaces      = lookup('interfaces', Hash[String[1], Data, 1], 'hash')

  # Data handle.
  $interfaces         = ::network::fill_interfaces($ifaces, $inventory_networks)
  $default_dns        = [
                         '8.8.8.8',
                         '8.8.4.4',
                        ]
  $default_ntp        = [
                         '0.debian.pool.ntp.org',
                         '1.debian.pool.ntp.org',
                         '2.debian.pool.ntp.org',
                         '3.debian.pool.ntp.org',
                        ]
  $dns_servers        = ::network::get_param($interfaces, $inventory_networks,
                                             'dns_servers', $default_dns)
  $dns_search         = ::network::get_param($interfaces, $inventory_networks,
                                             'dns_search', [ $::domain ])
  $ntp_servers        = ::network::get_param($interfaces, $inventory_networks,
                                      'ntp_servers', $default_ntp)
  $defaut_stage       = 'network'
  $supported_distribs = [ 'trusty', 'jessie' ];

  {
    network::restart                 => false,
    network::interfaces              => $interfaces,
    network::supported_distributions => $supported_distribs,
    network::stage                   => $defaut_stage,

    network::resolv_conf::domain                  => $::domain,
    network::resolv_conf::search                  => $dns_search,
    network::resolv_conf::nameservers             => $dns_servers,
    network::resolv_conf::timeout                 => 2,
    network::resolv_conf::supported_distributions => $supported_distribs,
    network::resolv_conf::stage                   => $defaut_stage,

    network::ntp::interfaces              => 'all',
    network::ntp::ntp_servers             => $ntp_servers,
    network::ntp::subnets_authorized      => 'all',
    network::ntp::ipv6                    => false,
    network::ntp::supported_distributions => $supported_distribs,
  }

}



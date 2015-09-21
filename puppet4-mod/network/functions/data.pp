function network::data {

  $inventory_networks = lookup('inventory_networks', Hash[String[1], Data, 1], 'hash')
  $ifaces             = lookup('interfaces', Hash[String[1], Data, 1], 'hash');
  $interfaces         = ::network::fill_interfaces($ifaces, $inventory_networks)
  # We have filled the '__default__' values in $interfaces.


  $default_dns = [ '8.8.8.8', '8.8.4.4' ]
  $default_ntp = [ '0.debian.pool.ntp.org',
                           '1.debian.pool.ntp.org',
                           '2.debian.pool.ntp.org',
                           '3.debian.pool.ntp.org',
                 ]

  $nameservers = ::network::get_param($interfaces, $inventory_networks,
                                      'nameservers', $default_dns)
  $search      = ::network::get_param($interfaces, $inventory_networks,
                                      'search', $::domain)
  $ntp_servers = ::network::get_param($interfaces, $inventory_networks,
                                      'ntp_servers', $default_ntp)


  { network::restart                 => false,
    network::interfaces              => $interfaces,
    network::supported_distributions => [ 'trusty', 'jessie' ],
    network::stage                   => 'network',

    network::resolv_conf::domain      => $::domain,
    network::resolv_conf::search      => $search,
    network::resolv_conf::nameservers => $nameservers,
    network::resolv_conf::timeout     => 2,

    # This is not a puppet class here, but the value could
    # be used by another classes (like a ntp puppet class
    # for instance).
    network::ntp_servers              => $ntp_servers
  }

}



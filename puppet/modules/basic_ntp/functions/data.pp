function basic_ntp::data {

  if !defined(Class['::network::params']) { include '::network::params' }
  $interfaces         = $::network::params::interfaces
  $inventory_networks = $::network::params::inventory_networks

  $default_ntp = [
                  '0.debian.pool.ntp.org',
                  '1.debian.pool.ntp.org',
                  '2.debian.pool.ntp.org',
                  '3.debian.pool.ntp.org',
                 ]

  $servers = ::network::get_param($interfaces, $inventory_networks,
                                  'ntp_servers', $default_ntp)

  $supported_distribs = [ 'trusty', 'jessie' ];

  {
    basic_ntp::params::interfaces         => 'all',
    basic_ntp::params::servers            => $servers,
    basic_ntp::params::subnets_authorized => 'all',
    basic_ntp::params::ipv6               => false,
    basic_ntp::supported_distributions    => $supported_distribs,
  }

}



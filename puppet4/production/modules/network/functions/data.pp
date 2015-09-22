function network::data {

  # Data lookup in hiera or in the environment.conf.
  $inventory_networks = lookup('inventory_networks', Hash[String[1], Data, 1],
                               'hash')
  $ifaces             = lookup('interfaces', Hash[String[1], Data, 1], 'hash')
  $hosts_conf         = lookup('hosts', Hash[String[1], Data], 'hash', {})

  # Data handle.
  $interfaces         = ::network::fill_interfaces($ifaces, $inventory_networks)
  $local_resolver     = true
  $override_dhcp      = false
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
  $default_stage      = 'network'

  # Default is no tag and the one basic hosts entry.
  $default_hosts_tag = ''
  $default_hosts_entries = { '127.0.1.1' => [$::fqdn, $::hostname ] }

  if $hosts_conf.empty {
    $hosts_tag     = $default_hosts_tag
    $hosts_entries = $default_hosts_entries
  } else {
    if $hosts_conf.has_key('tag') {
      $hosts_tag = $hosts_conf['tag']
    } else {
      $hosts_tag = $default_hosts_tag
    }
    if $hosts_conf.has_key('entries') {
      $hosts_entries = $hosts_conf['entries']
    } else {
      $hosts_entries = $default_hosts_entries
    }
  }

  $supported_distribs = [ 'trusty', 'jessie' ];

  {
    network::restart                 => false,
    network::interfaces              => $interfaces,
    network::supported_distributions => $supported_distribs,
    network::stage                   => $default_stage,

    network::resolv_conf::domain                  => $::domain,
    network::resolv_conf::search                  => $dns_search,
    network::resolv_conf::nameservers             => $dns_servers,
    network::resolv_conf::timeout                 => 2,
    network::resolv_conf::local_resolver          => $local_resolver,
    network::resolv_conf::override_dhcp           => $override_dhcp,
    network::resolv_conf::supported_distributions => $supported_distribs,
    network::resolv_conf::stage                   => $default_stage,

    network::hosts::entries                 => $hosts_entries,
    network::hosts::from_tag                => $hosts_tag,
    network::hosts::supported_distributions => $supported_distribs,
    network::hosts::stage                   => $default_stage,

    network::ntp::interfaces              => 'all',
    network::ntp::ntp_servers             => $ntp_servers,
    network::ntp::subnets_authorized      => 'all',
    network::ntp::ipv6                    => false,
    network::ntp::supported_distributions => $supported_distribs,
  }

}



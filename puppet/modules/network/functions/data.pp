function network::data {

  # Data lookup in hiera or in the environment.conf.
  $inventory_networks = lookup('inventory_networks', Hash[String[1], Data, 1],
                               'hash')
  $ifaces             = lookup('interfaces', Hash[String[1], Data, 1], 'hash')
  $hosts_conf         = lookup('hosts', Hash[String[1], Data], 'hash', {})

  # Data handle.
  $interfaces         = ::network::fill_interfaces($ifaces, $inventory_networks)
  $local_resolver     = true
  $lr_interface       = []
  $lr_access_control  = []
  $override_dhcp      = false
  $default_dns        = [
                         '8.8.8.8',
                         '8.8.4.4',
                        ]
  $default_timeout    = 5
  $dns_servers        = ::network::get_param($interfaces, $inventory_networks,
                                             'dns_servers', $default_dns)
  $dns_search         = ::network::get_param($interfaces, $inventory_networks,
                                             'dns_search', [ $::domain ])
  $default_stage      = 'network'

  # Default is no tag and the one basic hosts entry.
  $default_hosts_tag = ''
  $default_hosts_entries = { '127.0.1.1' => [ $::fqdn, $::hostname ] }

  case $hosts_conf.has_key('entries') {
    true:  { $hosts_entries = $hosts_conf['entries'] }
    false: { $hosts_entries = $default_hosts_entries }
  }

  case $hosts_conf.has_key('tag') {
    true:  { $hosts_tag = $hosts_conf['tag'] }
    false: { $hosts_tag = $default_hosts_tag }
  }

  # If '127.0.1.1' is not present in hosts entries and if
  # $::fqdn _and_ $::hostname are not present at all in any
  # hosts entries, we add the automatically $default_hosts_entries.
  $fqdn_hostname_not_in = $hosts_entries.values.filter |$addresses| {
      $addresses.member($::fqdn) or $addresses.member($::hostname)
  }.empty

  case [ $hosts_entries.has_key('127.0.1.1'), $fqdn_hostname_not_in ] {

    [ false, true ]: {
      $hosts_entries_filled = $default_hosts_entries + $hosts_entries
    }

    [ default, default ]: {
      $hosts_entries_filled = $hosts_entries
    }

  }

  $smtp_relay = ::network::get_param($interfaces, $inventory_networks,
                                     'smtp_relay', "smtp.${::domain}")
  $smtp_port  = ::network::get_param($interfaces, $inventory_networks,
                                     'smtp_port', 25)


  $supported_distribs = [ 'trusty', 'jessie' ];

  {
    network::params::inventory_networks            => $inventory_networks,
    network::params::interfaces                    => $interfaces,
    network::params::restart                       => false,
    network::params::resolvconf_domain             => $::domain,
    network::params::resolvconf_search             => $dns_search,
    network::params::resolvconf_timeout            => $default_timeout,
    network::params::resolvconf_override_dhcp      => $override_dhcp,
    network::params::dns_servers                   => $dns_servers,
    network::params::local_resolver                => $local_resolver,
    network::params::local_resolver_interface      => $lr_interface,
    network::params::local_resolver_access_control => $lr_access_control,
    network::params::hosts_entries                 => $hosts_entries_filled,
    network::params::hosts_from_tag                => $hosts_tag,
    network::params::smtp_relay                    => $smtp_relay,
    network::params::smtp_port                     => $smtp_port,

    network::supported_distributions => $supported_distribs,
    network::stage                   => $default_stage,

    network::resolv_conf::supported_distributions => $supported_distribs,
    network::resolv_conf::stage                   => $default_stage,

    network::hosts::supported_distributions => $supported_distribs,
    network::hosts::stage                   => $default_stage,
  }

}



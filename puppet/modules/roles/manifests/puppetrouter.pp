class roles::puppetrouter {

  # dnsmasq will be the local DNS server.
  # So we avoid conflict with unbound.
  class { '::network::resolv_conf::params':
    local_resolver => false,
  }

  include '::network::params'

  $dhcp_ifaces = $::network::params::interfaces.filter |$iface, $settings| {
    'inet' in $settings
       and $settings['inet']['method'] == 'dhcp'
       and 'in_networks' in $settings
       and $settings['in_networks'].size == 1
  }
  .filter |$iface, $settings| {
    $network = $settings['in_networks'][0]
    'dns_servers' in $::network::params::inventory_networks[$network]
  }
  .keys

  unless $dhcp_ifaces.size == 1 {
    fail('boum')
  }


  include '::roles::puppetserver'
  include '::roles::pxeserver'

}



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
  }.keys

  unless $dhcp_ifaces.size == 1 {
    fail('boum')
  }

  $dhcp_iface          = $dhcp_ifaces[0]
  $dhcp_iface_settings = $::network::params::interfaces[$dhcp_iface]

  unless 'in_networks' in $dhcp_iface_settings
  and $dhcp_iface_settings['in_networks'].size == 1 {
    fail('bam')
  }

  $dhcp_network_name = $dhcp_iface_settings['in_networks'][0]
  $dhcp_network      = $::network::params::inventory_networks[$dhcp_network_name]

  unless 'dns_servers' in $dhcp_network {
    fail('bim')
  }

  $dns_servers = $dhcp_network['dns_servers']


  include '::roles::puppetserver'

  class {'::roles::pxeserver::params':
    no_dhcp_interfaces => [ $dhcp_iface ],
  }
  include '::roles::pxeserver'

}



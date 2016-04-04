class network::params (

  Hash[String[1], Data, 1] $inventory_networks,
  Hash[String[1], Data, 1] $ifaces,
  Hash[String[1], Data, 1] $interfaces = ::network::fill_interfaces($ifaces, $inventory_networks),
  Boolean                  $restart    = false,

  String[1]                       $resolvconf_domain             = $::domain,
  Array[String[1], 1]             $resolvconf_search             = ::network::get_param($interfaces, $inventory_networks, 'dns_search', [$::domain]),
  Integer[1]                      $resolvconf_timeout            = 5,
  Boolean                         $resolvconf_override_dhcp      = false,
  Array[String[1], 1]             $dns_servers                   = ::network::get_param($interfaces, $inventory_networks, 'dns_servers'),
  Boolean                         $local_resolver                = true,
  Array[String[1]]                $local_resolver_interface      = [],
  Array[ Array[String[1], 2, 2] ] $local_resolver_access_control = [],


  Hash[ String[1], Array[String[1],1] ] $hosts          = {},
  Hash[ String[1], Array[String[1],1] ] $hosts_entries  = ::network::complete_hosts_entries($hosts),
  String                                $hosts_from_tag = '',

  String[1]  $smtp_relay = ::network::get_param($interfaces, $inventory_networks, 'smtp_relay'),
  Integer[1] $smtp_port  = ::network::get_param($interfaces, $inventory_networks, 'smtp_port', 25),

) {
}



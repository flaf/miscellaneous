class network::params (

  Hash[String[1], Data, 1] $inventory_networks,
  Hash[String[1], Data, 1] $ifaces,
  Hash[String[1], Data, 1] $interfaces = ::network::fill_interfaces($ifaces, $inventory_networks),
  Boolean                  $restart    = false,

  String[1]                       $resolvconf_domain             = $::domain,
  Array[String[1], 1]             $resolvconf_search             = ::network::get_param($interfaces, $inventory_networks, 'dns_search', [$::domain]),
  Integer[1]                      $resolvconf_timeout            = 5,
  Boolean                         $resolvconf_override_dhcp      = false,
  # $dns_servers can be undef for instance in a DHCP network
  # where /etc/resolv.conf is not managed by default.
  Optional[ Array[String[1], 1] ] $dns_servers                   = ::network::get_param($interfaces, $inventory_networks, 'dns_servers'),
  Boolean                         $local_resolver                = true,
  Array[String[1]]                $local_resolver_interface      = [],
  Array[ Array[String[1], 2, 2] ] $local_resolver_access_control = [],


  Hash[ String[1], Array[String[1],1] ] $hosts          = {},
  Hash[ String[1], Array[String[1],1] ] $hosts_entries  = ::network::complete_hosts_entries($hosts),
  String                                $hosts_from_tag = '',

  # Parameter below currently unused. <= TODO: False! It's used by flaf-moo.
  #                                      Bad idea, this should be in a role class.
  #                                      Remove it asap when "moo" will be roles.
  #
  # The $smtp_relay parameter can be undef (via the
  # "Optional[...]" instruction), because there is no
  # relevant default value and it's possible to have no smtp
  # relay in a network.
  Optional[String[1]] $smtp_relay = ::network::get_param($interfaces, $inventory_networks, 'smtp_relay'),
  Integer[1]          $smtp_port  = ::network::get_param($interfaces, $inventory_networks, 'smtp_port', 25),

) {
}



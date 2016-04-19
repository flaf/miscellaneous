class network::params (

  Hash[String[1], Data, 1] $inventory_networks,
  Hash[String[1], Data, 1] $ifaces,
  Hash[String[1], Data, 1] $interfaces = ::network::fill_interfaces($ifaces, $inventory_networks),
  Boolean                  $restart    = false,
  Array[String[1], 1]      $supported_distributions,

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

  ::homemade::is_supported_distrib($supported_distributions, $title)

}



# The $restart parameter is deprecated now.
class network::params (

  Network::Inventory       $inventory_networks,
  Hash[String[1], Data, 1] $ifaces,
  Hash[String[1], Data, 1] $interfaces = ::network::fill_interfaces($ifaces, $inventory_networks),
  #Boolean                  $restart    = false,
  Array[String[1], 1]      $supported_distributions,
) {
}



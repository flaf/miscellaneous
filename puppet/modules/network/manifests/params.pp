# The $restart parameter is deprecated now.
class network::params (

  Network::Inventory       $inventory_networks,
  Hash[String[1], Data, 1] $ifaces,
  Hash[String[1], Data, 1] $interfaces = ::network::fill_interfaces($ifaces, $inventory_networks),
  #Boolean                  $restart    = false,
  Array[String[1], 1]      $supported_distributions,
) {

  # Supplementary checks of $inventory_networks.
  $inventory_networks.each |$netname, $settings| {
    if ('pgp_keyserver' in $settings and $settings['pgp_keyserver']['proxy_required']) {
      unless ('http_proxy' in $settings) {
        @("END"/L$).fail
          ${title}: problem with the parameter `\$::network::params::inventory_networks` \
          where the network `${netname}` has a PGP keyserver with a required HTTP proxy \
          but the `http_proxy` key is not defined in this network.
          |-END
      }
    }
  }

}



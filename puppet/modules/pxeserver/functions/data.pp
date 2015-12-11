function pxeserver::data {

  $inventory_networks = lookup('inventory_networks', Hash[String[1], Data],
                               'hash', {})

  $dhcp_conf = $inventory_networks.reduce({}) |$memo, $entry| {

    $netname  = $entry[0]
    $settings = $entry[1]

    if $settings.has_key('dhcp_range') {

      $dhcp_range = $settings['dhcp_range']
      $vlan_id    = $settings['vlan_id']
      $cidr       = $settings['cidr_address']

      unless $dhcp_range =~ Array[String[1], 2, 2] {
        regsubst(@("END"), '\n', ' ', 'G').fail
          $title: sorry in a inventory networks the value of
          `dhcp_range` must be an array of 2 non-empty strings.
          Currently, this is not the case for the network `$netmane`.
          |- END
      }

      $netmask = $cidr.regsubst(/^.*\//, '')

      $range = { 'range' => $settings['dhcp_range'] + [ $netmask ] }

      if $settings.has_key('gateway') {
        $router = { 'router' => $settings['gateway'] }
      } else {
        $router = {}
      }

      if $settings.has_key('dns_servers') {
        $dns = { 'dns-server' => $settings['dns_servers'] }
      } else {
        $dns = {}
      }

      $a_dhcp_conf = { "vlan${vlan_id}" => $range + $router + $dns }

    } else {

      $a_dhcp_conf = {}

    };

    $memo + $a_dhcp_conf

  }

  $tags_excluded = []
  $tags_included = 'all'

  # Puppet part.
  $puppet_collection      = lookup('repository::puppet::collection',
                                   String[1], 'first', 'NOT-DEFINED')
  $pinning_puppet_version = lookup('repository::puppet::pinning_agent_version',
                                   String[1], 'first', 'NOT-DEFINED')
  $puppet_server          = lookup('puppetagent::server',
                                   String[1], 'first', 'NOT-DEFINED')
  $puppet_ca_server       = lookup('puppetagent::ca_server',
                                   String[1], 'first', 'NOT-DEFINED');

  {
    pxeserver::dhcp_conf               => $dhcp_conf,
    pxeserver::tags_excluded           => $tags_excluded,
    pxeserver::tags_included           => $tags_included,
    pxeserver::ip_reservations         => {},
    pxeserver::puppet_collection       => $puppet_collection,
    pxeserver::pinning_puppet_version  => $pinning_puppet_version,
    pxeserver::puppet_server           => $puppet_server,
    pxeserver::puppet_ca_server        => $puppet_ca_server,
    pxeserver::supported_distributions => [ 'trusty' ],
  }

}



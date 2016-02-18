function pxeserver::data {

  # Puppet part.
  if !defined(Class['::repository::params']) { include '::repository::params' }
  include '::repository::params'
  $puppet_collection      = $::repository::params::puppet_collection
  $pinning_puppet_version = $::repository::params::puppet_pinning_agent_version

  if !defined(Class['::puppetagent::params']) { include '::puppetagent::params' }
  $puppet_server    = $::puppetagent::params::server
  $puppet_ca_server = $::puppetagent::params::ca_server

  if !defined(Class['::network::params']) { include '::network::params' }
  $inventory_networks = $::network::params::inventory_networks

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
  $tags_included = 'all';

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



class roles::pxeserver {

  # This present role include the role "generic".
  include '::roles::generic'

  include '::repository::puppet::params'
  include '::puppetagent::params'
  include '::network::params'

  # We filter the networks which are candidates.
  $networks = $::network::params::inventory_networks.filter |$entry| {
    $settings = $entry[1];
    $::datacenter in $settings['datacenters'] and 'dhcp_range' in $settings
  }

  if $networks.empty {
    @("END"/L).fail
      ${title}: sorry, there no network candidate to be in \
      the DHCP configuration of this PXE server. Check the \
      `dhcp_range` and `datacenters` properties in the inventory \
      networks.
      |-END
  }

  $dhcp_confs = $networks.reduce({}) |$memo, $entry| {

    [$netname, $settings] = $entry

    $dhcp_range = $settings['dhcp_range']
    $vlan_id    = $settings['vlan_id']
    $cidr       = $settings['cidr_address']
    $netmask    = ::network::dump_cidr($cidr)['netmask']
    $tag        = "vlan${vlan_id}"

    if $tag in $memo {
      $netname2 = $memo[$tag]['netname']
      @("END"/L$).fail
        ${title}: the tag (vlan\${vlan_id}) `${tag}` is duplicated, \
        present in the networks ${netname} and ${netname2}.
        |-END
    };

    $memo + {
      $tag => {
        'range'      => $settings['dhcp_range'] + [ $netmask ],
        'router'     => $settings['gateway'],
        'dns-server' => $settings['dns_servers'],
        'netname'    => $netname,
      }
    }

  }

  class { '::pxeserver::params':
    dhcp_confs             => $dhcp_confs,
    puppet_collection      => $::repository::puppet::params::collection,
    pinning_puppet_version => $::repository::puppet::params::pinning_agent_version,
    puppet_server          => $::puppetagent::params::server,
    puppet_ca_server       => $::puppetagent::params::ca_server,
    puppet_apt_url         => $::repository::puppet::params::url,
    puppet_apt_key         => [ $::repository::puppet::params::url, 'pubkey.gpg' ].join('/'),
  }

  include '::pxeserver'

}



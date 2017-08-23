class roles::pxeserver (
  Optional[ Array[String[1]] ] $no_dhcp_interfaces = undef,
  Optional[ Array[String[1]] ] $apache_listen_to   = undef,
  Optional[ Array[String[1]] ] $backend_dns        = undef,
) {

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

  # Search a APT proxy.
  $apt_proxies = $networks.reduce([]) |$memo, $entry| {
    [ $netname, $settings ] = $entry
    case 'apt_proxy' in $settings {
      true:  {
        $proxy_address = $settings['apt_proxy']['address']
        $proxy_port    = $settings['apt_proxy']['port']
        $memo + "http://${proxy_address}:${proxy_port}"
      }
      false: {
        $memo
      }
    }
  }
  .unique

  # Set if only one candidate.
  $apt_proxy = $apt_proxies.size ? {
    1       => $apt_proxies[0],
    default => '',
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
      }.filter |$key, $value| { $value !~ Undef }
    }

  }

  $cron_update_di_name = 'update-di'

  class { '::pxeserver::params':
    dhcp_confs             => $dhcp_confs,
    no_dhcp_interfaces     => $no_dhcp_interfaces,
    apache_listen_to       => $apache_listen_to,
    backend_dns            => $backend_dns,
    cron_wrapper           => ::roles::wrap_cron_mon($cron_update_di_name),
    apt_proxy              => $apt_proxy,
    puppet_collection      => $::repository::puppet::params::collection,
    pinning_puppet_version => $::repository::puppet::params::pinning_agent_version,
    puppet_server          => $::puppetagent::params::server,
    puppet_ca_server       => $::puppetagent::params::ca_server,
    puppet_apt_url         => $::repository::puppet::params::url,
    puppet_apt_key_finger  => $::repository::puppet::params::apt_key_fingerprint,
  }

  include '::pxeserver'

  # Add a checpoint to check the update of D-I.

  $pxe_checkpoint_title = $::facts['networking']['fqdn'].with |$fqdn| {
    "${fqdn} from ${title}"
  }

  monitoring::host::checkpoint {$pxe_checkpoint_title:
    templates        => ['linux_tpl', 'http_tpl'],
    custom_variables => [
      {
        'varname' => '_crons',
        'value'   => {"cron-${cron_update_di_name}" => [$cron_update_di_name, '7d']},
        'comment' => ["Debian Installer should be updated weekly (${cron_update_di_name})."],
      }
    ],
  }

}



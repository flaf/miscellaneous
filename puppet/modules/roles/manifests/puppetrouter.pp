class roles::puppetrouter {

  # dnsmasq will be the local DNS server.
  # So we avoid conflict with unbound.
  class { '::network::resolv_conf::params':
    local_resolver => false,
  }

  include '::network::params'

  ### Check the network configuration
  ###
  ### In clear:
  ###
  ###     - only one interface configured with DHCP (it's the WAN interface)
  ###     - all interfaces must have the "in_networks" key defined and its
  ###       must contain only one network.
  ###     - the network of the only one DHCP (WAN) interface must have the
  ###       the key 'dns_servers' defined.
  ###
  $dhcp_ifaces = $::network::params::interfaces.filter |$iface, $settings| {
    'inet' in $settings
       and $settings['inet']['method'] == 'dhcp'
  }.keys

  unless $dhcp_ifaces.size == 1 {
    @("END"/L).fail
      ${title}: with this role, the number of interfaces configured \
      via DHCP must be 1 exactly. This is not the case currently.
      |-END
  }

  $::network::params::interfaces.each |$iface, $settings| {
    unless 'in_networks' in $settings and $settings['in_networks'].size == 1 {
      @("END"/L).fail
        ${title}: with this role, all interfaces must have the `in_networks` \
        key defined and its value must contain only one network. This is not \
        the case currently with the interface `${iface}`.
        |-END
    }
  }

  $dhcp_iface          = $dhcp_ifaces[0]
  $dhcp_iface_settings = $::network::params::interfaces[$dhcp_iface]
  $dhcp_network_name   = $dhcp_iface_settings['in_networks'][0]
  $dhcp_network        = $::network::params::inventory_networks[$dhcp_network_name]

  unless 'dns_servers' in $dhcp_network {
    @("END"/L).fail
      ${title}: with this role, the only one interface configured via DHCP \
      must belong to a network where the `dns_servers` key is defined. This \
      is not the case currently with the network `${dhcp_network_name}`.
      |-END
  }
  ### End of the network checking.


  $wan_dns_servers = $dhcp_network['dns_servers']

  $lans_cidr = $::network::params::interfaces.filter |$iface, $settings| {
    $iface != $dhcp_iface
  }
  .reduce([]) |$memo, $entry| {
    $a_network = $entry[1]['in_networks'][0]
    $a_cidr    = $::network::params::inventory_networks[$a_network]['cidr_address'];
    $memo + [ $a_cidr ]
  }
  .unique

  # It's a fucking hack to override /etc/resolv.conf after
  # the DHCP configuration.
  $override_resolv_content = @("END")
    ### This file is managed by Puppet, don't edit it. ###

    cat >/etc/resolv.conf <<EOF
    ### This file is managed by Puppet, don't edit it. ###
    search ${::domain}
    domain ${::domain}
    nameserver 127.0.0.1
    EOF

    | END

  file { '/etc/dhcp/dhclient-exit-hooks.d/override-resolv-conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $override_resolv_content,
  }



  # The /etc/fstab file and sshfs must be configured manually.
  $mount_puppet_content = @(END)
    #!/bin/sh

    ### This file is managed by Puppet, don't edit it. ###

    # Because this fucking "_netdev" option doesn't work.

    [ "$IFACE" != '--all' ] && exit 0

    sleep 1

    modules=/etc/puppetlabs/code/environments/production/modules
    hieradata=/etc/puppetlabs/code/environments/production/hieradata

    for m in "$modules" "$hieradata"
    do
        if ! mountpoint "$m" >/dev/null
        then
            mount "$m"
        fi
    done

    | END

  file { '/etc/network/if-up.d/mount-puppet-dir':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => $mount_puppet_content,
  }

  class { '::network::basic_router::params':
    #masqueraded_networks      => $lans_cidr,
    # We want to use masquerading only with the WAN interface.
    masqueraded_output_ifaces => [ $dhcp_iface ],
  }
  include '::network::basic_router'

  include '::roles::puppetserver'

  class {'::roles::pxeserver::params':
    no_dhcp_interfaces => [ $dhcp_iface ],
    backend_dns        => $wan_dns_servers,
  }
  include '::roles::pxeserver'

}



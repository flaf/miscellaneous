class roles::wproxyeleapoc (
  Boolean $rsyslog_allow_udp_reception = false,
) {

  include '::network::params'

  # The only interface with the 'wan' keyword is seen as the
  # WAN interface.
  $wan_iface = $::network::params::interfaces.filter |$iface, $settings| {
    ('keywords' in $settings) and ('wan' in $settings['keywords'])
  }

  unless $wan_iface.keys.size == 1 {
    @("END"/L).fail
      ${title}: with this role, the number of interfaces with the "wan" \
      keywords must be 1 exactly. This is not the case currently.
      |-END
  }

  # dnsmasq will be the DNS server and it will use the DNS
  # from the WAN network as DNS backend.
  $backend_dns = ::network::get_param(
                   $wan_iface,
                   $::network::params::inventory_networks,
                   'dns_servers'
                 )

  $wan_iface_name = $wan_iface.keys[0]
  $wan_address    = $::network::params::interfaces.dig($wan_iface_name, 'inet', 'options', 'address')
  unless $wan_address !~ Undef {
    @("END"/L).fail
      ${title}: with this role, the WAN interface must have \
      an IPv4 address.
      |-END
  }

  # Apache will listen to all addresses except the WAN
  # address which will be used by the Nginx reverse proxy.
  $all_ipv4_non_wan_ifaces = $::network::params::interfaces
    .filter |$iface, $settings| {
      $iface != $wan_iface_name
    }
    .reduce([]) |$memo, $entry| {
      $settings = $entry[1]
      $memo + $settings.dig('inet', 'options', 'address')
    }
    .filter |$address| { $address =~ NotUndef  }

  # Warning. dnsmasq is the local DNS server so we do not
  # want to have an unbound installed (to avoid port
  # conflict).
  class { '::network::resolv_conf::params':
    local_resolver => false,
    dns_servers    => [ '127.0.0.1' ] + $backend_dns,
  }

  class { '::roles::pxeserver':
    no_dhcp_interfaces => [ $wan_iface_name ],
    backend_dns        => $backend_dns,
    apache_listen_to   => $all_ipv4_non_wan_ifaces,
  }

  class { 'moo::quickwproxy::params':
    listen => [ $wan_address ],
  }
  include 'moo::quickwproxy'

  class { '::network::basic_router::params':
    masqueraded_output_ifaces => [ $wan_iface_name ],
  }
  include '::network::basic_router'

  $comment = $rsyslog_allow_udp_reception ? {
    true  => '',
    false => '#',
  }

  file_line { 'rsyslog_allow_udp_reception_1':
    path   => '/etc/rsyslog.conf',
    match  => '^[[:space:]]*#?[[:space:]]*\$ModLoad[[:space:]]+imudp([[:space:]]|$)',
    line   => "${comment}\$ModLoad imudp    # Line edited by Puppet",
    notify => Service['rsyslog'],
  }

  file_line { 'rsyslog_allow_udp_reception_2':
    ensure => present,
    path   => '/etc/rsyslog.conf',
    match  => '^[[:space:]]*#?[[:space:]]*\$UDPServerRun[[:space:]]514([[:space:]]|$)',
    line   => "${comment}\$UDPServerRun 514 # Line edited by Puppet",
    notify => Service['rsyslog'],
  }

  service { 'rsyslog':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }

}



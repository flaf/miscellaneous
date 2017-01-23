class roles::wproxyeleapoc {

  include '::network::params'

  # The only interface with the 'wan' keyword is seen as the
  # WAN interface.
  $wan_ifaces = $::network::params::interfaces.filter |$iface, $settings| {
    ('keywords' in $settings) and ('wan' in $settings['keywords'])
  }.keys

  unless $wan_ifaces.size == 1 {
    @("END"/L).fail
      ${title}: with this role, the number of interfaces with the "wan" \
      keywords must be 1 exactly. This is not the case currently.
      |-END
  }

  $wan_iface = $wan_ifaces[0]

  class { '::roles::pxeserver':
    no_dhcp_interfaces => [ $wan_iface ],
  }

  class { '::network::basic_router::params':
    masqueraded_output_ifaces => [ $wan_iface ],
  }
  include '::network::basic_router'

}



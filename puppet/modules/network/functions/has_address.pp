function network::has_address (
  Hash[String[1], Hash[String[1], Data, 1], 1] $interfaces,
  String[1]                                    $iface,
) {

  # In this function, we assume that "an interface has an IP
  # address" is equivalent to "an interface has a 'static' or
  # 'dhcp' method."

  unless $iface in $interfaces {
    @("END"/L).fail
      function `::network::has_address`: sorry the interface `${iface}` \
      in not present in the interfaces hash `${interfaces}`.
      |- END
  }

  $method  = $interfaces.dig($iface, 'inet', 'method')
  $method6 = $interfaces.dig($iface, 'inet6', 'method')

  $inet_addr = case $method {
    /^(static|dhcp)$/: { true  }
    default:           { false }
  }

  $inet6_addr = case $method6 {
    /^(static|dhcp)$/: { true  }
    default:           { false }
  };

  $inet_addr or $inet6_addr

}



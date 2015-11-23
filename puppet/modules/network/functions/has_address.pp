function network::has_address (
  Hash[String[1], Hash[String[1], Data, 1], 1] $interfaces,
  String[1]                                    $iface,
) {

  # In this function, we assume that "an interface has an IP
  # address" is equivalent to "an interface has a 'static' or
  # 'dhcp' method."

  unless $interfaces.has_key($iface) {
    @("END").regsubst('\n', ' ', 'G').fail
      function `::network::has_address`: sorry the interface `${iface}`
      in not present in the interfaces hash `${interfaces}`.
      |- END
  }

  if $interfaces[$iface].has_key('inet') {
    # 'method' key is mandatory
    $method = $interfaces[$iface]['inet']['method']
    if $method == 'static' or $method == 'dhcp' {
      $inet_addr = true
    } else {
      $inet_addr = false
    }
  }

  if $interfaces[$iface].has_key('inet6') {
    # 'method' key is mandatory
    $method = $interfaces[$iface]['inet6']['method']
    if $method == 'static' or $method == 'dhcp' {
      $inet6_addr = true
    } else {
      $inet6_addr = false
    }
  };

  $inet_addr or $inet6_addr

}



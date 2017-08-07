function monitoring::dummy2customvars (
  Monitoring::Hostname           $host_name,
  Monitoring::Address            $host_address,
  Optional[Monitoring::Address]  $ipmi_address,
  Optional[Monitoring::CheckDns] $check_dns,
) >> Array[Monitoring::CustomVariable, 1] {

  $init = {
    '_resolvconf_dns_lookups' => {},
    '_dns_lookups'            => {},
  }

  if $check_dns =~ Undef {

    $custom_variables = []

  } else {

    $custom_variables = $check_dns.reduce($init) |$memo, $item| {

      [$desc, $dns]     = $item
      $fqdn             = $dns['fqdn']
      $server           = $dns.dig('server')

      $expected_address = $dns.dig('expected-address').with |$exp_addr| {
        if $exp_addr == '$HOSTADDRESS$' { $host_address } else { $exp_addr }
      }

      $options          = $dns.dig('options')
        .then |$opts| { $opts }
        .lest || { '' }
        .with |$opts| {
          if $expected_address =~ Undef {
            $opts
          } else {
            "-a ${expected_address} ${opts}".regsubst(/ *$/, '', 'G')
          }
        }

      [$varname, $value] = if $server =~ Undef {
        ['_resolvconf_dns_lookups', {$desc => [$fqdn, $options]}]
      } else {
        ['_dns_lookups', {$desc => [$server, $fqdn, $options]}]
      }

      $memo + { $varname => $memo[$varname] + $value }

    }.filter |$k, $v| { !($v.empty) }.map |$k, $v| {
      { 'varname' => $k, 'value' => $v }
    }

  }

  $ipmi_address.then |$ipmi| {
    [{'varname' => '_ping_addresses', 'value' => {"ipmi.${host_name}" => [$ipmi]}}] + $custom_variables
  }.lest || {
    $custom_variables
  }

}



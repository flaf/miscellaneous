class monitoring::host {

  include '::monitoring::host::params'

  [
    $host_name,
    $address,
    $templates,
    $custom_variables,
    $extra_info,
    $monitored,
  ] = Class['::monitoring::host::params']

  $fqdn = $::facts['networking']['fqdn']

  monitoring::host::checkpoint {"${fqdn} from ${title}":
    host_name        => $host_name,
    address          => $address,
    templates        => $templates,
    custom_variables => $custom_variables,
    extra_info       => $extra_info,
    monitored        => $monitored,
  }

  monitoring::host::checkpoint {"${fqdn} add1":
    host_name        => $host_name,
    address          => $address,
    templates        => ['foo_tpl'],
    custom_variables => [
      { 'varname' => '_KEY', 'value' => 'xxxx' },
      { 'varname' => '_ARRAY', 'value' => ['a', 'b'] },
      { 'varname' => '_http', 'value' => {
                                          'key1' => ['v1', 'v2'],
                                         }},
    ],
    extra_info       => {'ipmi_address' => 'x.y.z.w'},
    monitored        => $monitored,
  }

  monitoring::host::checkpoint {"${fqdn} add2":
    host_name        => $host_name,
    address          => $address,
    custom_variables => [
      { 'varname' => '_ARRAY', 'value' => ['b', 'd'] },
      { 'varname' => '_http', 'value' => {
                                          'key2' => ['v1', 'v2'],
                                         }},
    ],
    extra_info       => {},
    monitored        => $monitored,
  }

}



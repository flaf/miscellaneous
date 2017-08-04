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
    templates        => ['foo_tpl'],
    custom_variables => [
      { 'varname' => '_KEY', 'value' => 'xxxx' },
      { 'varname' => '_ARRAY', 'value' => ['a', 'b'] },
      { 'varname' => '_http', 'value' => {
                                          'key1' => ['v1', 'v2'],
                                         }},
    ],
    extra_info       => {
      'ipmi_address' => 'x.y.z.w',
      'check_dns'    => {
                         'dns-google' => { 'fqdn' => 'wwww.google.fr', 'server' => '8.8.8.8', },
                         'dns-google2' => { 'fqdn' => 'wwww.google2.fr', 'server' => '8.8.8.8', },
                         'dns-google3' => { 'fqdn' => 'wwww.google3.fr', 'server' => '8.8.8.8', 'expected-address'=> '$HOSTADDRESS$' },
                         'dns-foo'    => { 'fqdn' => 'wwww.foo.fr', },
      },
      'blacklist'    => [
         {
          'contact'     => '.*',
          'description' => '^reboot$',
          'timeslots'   => '[00h00;23h59]',
          'weekdays'    => '*',
          'comment'     => ['blabla blabla', 'bloblo bloblo...'],
         },
       ],
    },
  }

  monitoring::host::checkpoint {"${fqdn} add2":
    host_name        => $host_name,
    custom_variables => [
      { 'varname' => '_ARRAY', 'value' => ['b', 'd'] },
      { 'varname' => '_http', 'value' => {
                                          'key2' => ['v1', 'v2'],
                                         }},
    ],
    extra_info       => {
      'check_dns'    => {
                         'dns-bar' => { 'fqdn' => 'wwww.bar.fr', },
      },
      'blacklist'    => [
         {
          'contact'     => '.*',
          'description' => '^foo$',
          'timeslots'   => '[00h00;00h59]',
          'weekdays'    => [1,2],
         },
      ],
    },
  }

  monitoring::host::checkpoint {"srv.dom.tld":
    host_name        => 'asrv.dom.tld',
    address          => 'a.b.c.d',
    templates        => ['foo_tpl'],
    #custom_variables => [
    #  { 'varname' => '_ARRAY', 'value' => ['b', 'd'] },
    #],
    extra_info       => {
      'ipmi_address' => 'x.y.z.w',
      'check_dns'    => {
        'dns-google3' => { 'fqdn' => 'wwww.google3.fr', 'server' => '8.8.8.8', 'expected-address'=> '$HOSTADDRESS$' },
      },
    #  'blacklist'    => [
    #     {
    #      'contact'     => '.*',
    #      'description' => '^foo$',
    #      'timeslots'   => '[00h00;00h59]',
    #      'weekdays'    => [1,2],
    #     },
    #  ],
    },
    monitored        => false,
  }

}



class roles::memcached {

  include '::roles::generic'
  include '::memcached'

  $fqdn = $::facts['networking']['fqdn']

  monitoring::host::checkpoint {"${fqdn} from ${title}":
    templates        => ['linux_tpl', 'memcached_tpl'],
    custom_variables => [
      {
        'varname' => '_present_processes',
        'value'   => {'process-memcached' => ['memcached']},
      },
    ],
  }

}



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

}



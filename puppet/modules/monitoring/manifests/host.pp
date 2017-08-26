class monitoring::host {

  include '::monitoring::host::params'

  [
    $host_name,
    $address,
    $templates,
    $custom_variables,
    $extra_info,
    $ipmi_template,
    $monitored,
  ] = Class['::monitoring::host::params']

  $fqdn = $::facts['networking']['fqdn']

  $final_templates = if 'ipmi_address' in $extra_info and $ipmi_template !~ Undef {
    $templates + [$ipmi_template]
  } else {
    $templates
  }

  monitoring::host::checkpoint {"${fqdn} from class ${title}":
    host_name        => $host_name,
    address          => $address,
    templates        => $final_templates,
    custom_variables => $custom_variables,
    extra_info       => $extra_info,
    monitored        => $monitored,
  }

}



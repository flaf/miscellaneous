class monitoring::host::params (
  Monitoring::Hostname              $host_name,
  Monitoring::Address               $address,
  Array[Monitoring::Template]       $templates,
  Array[Monitoring::CustomVariable] $custom_variables,
  Monitoring::ExtraInfo             $extra_info,
  Optional[Monitoring::Template]    $ipmi_template,
  Boolean                           $monitored,
) {
}



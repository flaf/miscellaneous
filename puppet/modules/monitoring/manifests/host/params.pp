class monitoring::host::params (
  Monitoring::Hostname              $host_name,
  String[1]                         $address,
  Array[Monitoring::Template]       $templates = [],
  Array[Monitoring::CustomVariable] $custom_variables = [],
  Array[Monitoring::ExtraInfo]      $extra_info = [],
  Boolean                           $monitored,
) {
}



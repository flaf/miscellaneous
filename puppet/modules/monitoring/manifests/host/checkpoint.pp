define monitoring::host::checkpoint (
  Monitoring::Hostname              $host_name = $::facts['networking']['fqdn'],
  Optional[Monitoring::Address]     $address = undef,
  Array[Monitoring::Template]       $templates = [],
  Array[Monitoring::CustomVariable] $custom_variables = [],
  Monitoring::ExtraInfo             $extra_info = {},
  Optional[Boolean]                 $monitored = undef,
) {

  if $templates.empty and $custom_variables.empty and $extra_info.empty {
    @("END"/L$).fail
      Problem with the defined resource `Monitoring::Host::Checkpoint['${title}']` \
      where the parameters `templates`, `custom_variables` and `extra_info` \
      are simultaneously empty which not allowed.
      |- END
  }

}



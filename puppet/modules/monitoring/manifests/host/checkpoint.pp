define monitoring::host::checkpoint (
  Monitoring::Hostname              $host_name = $::facts['networking']['fqdn'],
  Optional[Monitoring::Address]     $address = undef,
  Array[Monitoring::Template]       $templates = [],
  Array[Monitoring::CustomVariable] $custom_variables = [],
  Monitoring::ExtraInfo             $extra_info = {},
  Optional[Boolean]                 $monitored = undef,
) {

  # At least one of $templates, $custom_variables or
  # $extra_info must be not empty.
  if $templates.empty and $custom_variables.empty and $extra_info.empty {
    @("END"/L$).fail
      Problem with the defined resource `Monitoring::Host::Checkpoint['${title}']` \
      where the parameters `templates`, `custom_variables` and `extra_info` \
      are simultaneously empty which not allowed.
      |- END
  }

  # If not empty, $custom_variables must contain variables
  # with different varname.
  unless $custom_variables.empty {
    $custom_variables.reduce([]) |$memo, $var| {
      $varname = $var['varname']
      if $varname in $memo {
        @("END"/L$).fail
          Problem with the defined resource `Monitoring::Host::Checkpoint['${title}']` \
          and its parameter `custom_variables` which contains two variables with the \
          same `varname`. This is not allowed.
          |- END
      }
      $memo + [$varname]
    }
  }

}



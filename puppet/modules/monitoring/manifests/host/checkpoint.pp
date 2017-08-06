define monitoring::host::checkpoint (
  Monitoring::Hostname              $host_name = $::facts['networking']['fqdn'],
  Optional[Monitoring::Address]     $address = undef,
  Array[Monitoring::Template]       $templates = [],
  Array[Monitoring::CustomVariable] $custom_variables = [],
  Monitoring::ExtraInfo             $extra_info = {},
  Optional[Boolean]                 $monitored = undef,
) {

  # A checkpoint resource does absolutely nothing, and
  # manages no resources. It will be just used during
  # collecting via a Puppetdb query.

  # At least one of $templates, $custom_variables or
  # $extra_info must be not empty. If the three of them are
  # simultaneously empty, the checkpoint resource has no use
  # and no sense.
  if $templates.empty and $custom_variables.empty and $extra_info.empty {
    @("END"/L$).fail
      Problem with the defined resource \
      `Monitoring::Host::Checkpoint['${title}']` where the parameters \
      `templates`, `custom_variables` and `extra_info` are simultaneously \
      empty which not allowed.
      |- END
  }

  # If not empty, $templates must contain different
  # templates two by two.
  unless $templates.empty {
    $templates.reduce([]) |$memo, $template| {
      if $template in $memo {
        @("END"/L$).fail
          Problem with the defined resource \
          `Monitoring::Host::Checkpoint['${title}']` and its Array \
          parameter `templates` which contains the template \
          `${template}` twice (at least). This is not allowed, the \
          templates must be different two by two.
          |- END
      }
      $memo + [$template]
    }
  }

  # If not empty, $custom_variables must contain variables
  # with different varname two by two.
  unless $custom_variables.empty {
    $custom_variables.reduce([]) |$memo, $var| {
      $varname = $var['varname']
      if $varname in $memo {
        @("END"/L$).fail
          Problem with the defined resource \
          `Monitoring::Host::Checkpoint['${title}']` and its Array \
          parameter `custom_variables` which contains two variables \
          with the same `varname`. This is not allowed, the varnames \
          must be different two by two.
          |- END
      }
      $memo + [$varname]
    }
  }

}



class keepalived_vip::params (
  Hash[String[1], Keepalived_vip::VrrpScript]      $vrrp_scripts,
  Hash[String[1], Keepalived_vip::VrrpInstance, 1] $vrrp_instances,
  Boolean                                          $cron_check_vip,
  String[1]                                        $cron_check_cmd,
  Array[String[1], 1]                              $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $default = {
    'nopreempt'    => false,
    'track_script' => undef,
  }

  # Default values are just explicitly added.
  $vrrp_instances_updated = $vrrp_instances.reduce({}) |$memo, $entry| {
    [ $instance_name , $settings ] = $entry;
    $memo + { $instance_name => $default + $settings }
  }

  # Check that there is no duplicated virtual_router_id.
  $ids = $vrrp_instances_updated.reduce([]) |$memo, $entry| {
    [ $name, $settings ] = $entry;
    $memo << $settings['virtual_router_id']
  }

  unless $ids.size == $ids.unique.size {
    @("END"/L).fail
       $title: sorry, in the `vrrp_instances` parameter, you do not have \
       duplicated virtual_router_id.
       |-END
  }

  # Check that the 'track_script' key is valid in the case
  # where the value is a string. In this case the string
  # must be present in the keys of $vrrp_scripts.
  $vrrp_instances_updated.each |$entry| {

    [ $instance_name, $settings ] = $entry
    $track_script                 = $settings['track_script']

    if $track_script =~ String[1] {
      unless $track_script in $vrrp_scripts {
        @("END"/L).fail
          $title: in the parameter `vrrp_instances`, the track_script
          `${track_script}` of the instance ${instance_name} is not referenced \
          in the `vrrp_scripts` parameter. The track_script name must be a key \
          of the hash `vrrp_scripts`.
          |-END
      }
    }

  }

}



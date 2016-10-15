class keepalived_vip {

  include '::keepalived_vip::params'
  $vrrp_scripts           = $::keepalived_vip::params::vrrp_scripts
  $vrrp_instances_updated = $::keepalived_vip::params::vrrp_instances_updated
  $cron_check_vip         = $::keepalived_vip::params::cron_check_vip
  $cron_check_cmd         = $::keepalived_vip::params::cron_check_cmd

  class { '::keepalived':
    config_file_mode => '0640',
  }

  $vrrp_instances_updated.reduce([]) |$memo_declared_checks, $entry| {

    [ $instance_name, $settings ] = $entry
    $check                        = $settings['track_script']

    # We need to check the type of $check and if it is in
    # $memo_declared_checks.
    case [ $check, $check in $memo_declared_checks ] {

      [ Keepalived_vip::VrrpScript, default ]: {

        # In this case, we have to declare a
        # "keepalived::vrrp::script" resource.
        $additional   = []
        $track_script = "script_${instance_name}"

        keepalived::vrrp::script { $track_script:
          script   => $check['script'],
          interval => $check['interval'],
          weight   => $check['weight'],
        }

      }

      [ String[1], false ]: {

        # In this case, the resource must be declared
        # and $memo_declared_checks will be updated.
        $additional   = [ $check ]
        $track_script = $check

        keepalived::vrrp::script { $track_script:
          script   => $vrrp_scripts[$check]['script'],
          interval => $vrrp_scripts[$check]['interval'],
          weight   => $vrrp_scripts[$check]['weight'],
        }

      }

      [ String[1], true ]: {

        # In this case, the resource must not be declared,
        # no update concerning $memo_declared_checks, but
        # we have to set the $track_script variable used
        # in the keepalived::vrrp::instance resource below.
        $additional   = []
        $track_script = $check

      }

      [ default, default ]: {

        $additional   = []
        $track_script = undef

      }

    }

    keepalived::vrrp::instance { $instance_name:
      state             => $settings['state'],
      nopreempt         => $settings['nopreempt'],
      interface         => $settings['interface'],
      virtual_router_id => $settings['virtual_router_id'],
      priority          => $settings['priority'],
      auth_type         => $settings['auth_type'],
      auth_pass         => $settings['auth_pass'],
      virtual_ipaddress => $settings['virtual_ipaddress'],
      track_script      => $track_script,
    };

    unique($memo_declared_checks + $additional)

  }

  case $cron_check_vip {

    true: {
      $all_vips         = $vrrp_instances_updated.reduce([]) |$memo, $entry| {
        [ $instance_name, $settings ] = $entry;
        unique($settings['virtual_ipaddress'] + $memo)
      }
      $ensure_cron_bin  = 'present'
      $content_cron_bin = epp('keepalived_vip/check_vip.epp', { 'all_vips' => $all_vips })
      $ensure_cron      = 'present'
    }

    false: {
      $all_vips         = [ 'foo' ] # unused in this case.
      $ensure_cron_bin  = 'absent'
      $content_cron_bin = 'bar'     # unused in this case.
      $ensure_cron      = 'absent'
    }

  }

  file { '/usr/local/bin/check-vip':
    ensure  => $ensure_cron_bin,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => $content_cron_bin,
  }

  cron { 'cron-check-vip':
    ensure  => $ensure_cron,
    user    => 'root',
    command => $cron_check_cmd,
    minute  => '*/5',
    require => File['/usr/local/bin/check-vip'],
  }

}



# TODO: 1. add a cron feature to launch run puppet.
#       2. Write the README file.
class puppetagent (
  Boolean             $service_enabled,
  String[1]           $runinterval,
  String[1]           $server,
  String[1]           $collection,
  String[1]           $package_version,
  String[1]           $stage_package,
  Boolean             $src,
  Boolean             $module_off,
  Array[String[1], 1] $supported_distributions,
) {

  if ! $module_off {

    ::homemade::is_supported_distrib($supported_distributions, $title)

    require '::puppetagent::package'

    if $service_enabled {
      $ensure_value = 'running'
      $enable_value = true
      $notify       = Service['puppet']
    } else {
      $ensure_value = 'stopped'
      $enable_value = false
      $notify       = undef # Do not refresh the service in this case.
    }

    file { '/etc/puppetlabs/puppet/puppet.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => epp( 'puppetagent/puppet.conf.epp',
                      { 'server'       => $server,
                        'runinterval'  => $runinterval,
                      }
                    ),
      before  => Service['puppet'],
      notify  => $notify,
    }

    service { 'puppet':
      ensure     => $ensure_value,
      enable     => $enable_value,
      hasrestart => true,
      hasstatus  => true,
    }

  } else {

    # Do nothing.

  }

}



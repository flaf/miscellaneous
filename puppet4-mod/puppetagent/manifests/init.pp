class puppetagent (
  Boolean             $service_enabled,
  String[1]           $runinterval,
  String[1]           $server,
  Boolean             $manage_puppetconf,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  require '::repository::puppet'

  ensure_packages(['puppet-agent'], { ensure => present, })

  if $service_enabled {
    $ensure_value = 'running'
    $enable_value = true
    $notify       = Service['puppet']
  } else {
    $ensure_value = 'stopped'
    $enable_value = false
    $notify       = undef # Do not refresh the service in this case.
  }

  if $manage_puppetconf {

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
      require => Package['puppet-agent'],
      before  => Service['puppet'],
      notify  => $notify,
    }

  }

  service { 'puppet':
    ensure     => $ensure_value,
    enable     => $enable_value,
    hasrestart => true,
    hasstatus  => true,
  }

}



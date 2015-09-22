class puppetagent (
  Boolean                                 $service_enabled,
  String[1]                               $runinterval,
  Enum['per-day', 'per-week', 'disabled'] $cron,
  String[1]                               $server,
  String[1]                               $ca_server,
  Boolean                                 $manage_puppetconf,
  Array[String[1], 1]                     $supported_distributions,
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
                      {
                        'server'      => $server,
                        'ca_server'   => $ca_server,
                        'runinterval' => $runinterval,
                      }
                    ),
      require => Package['puppet-agent'],
      before  => Service['puppet'],
      notify  => $notify,
    }

  }

  # TODO: to ensure the Unix rights of the host private key.
  # Indeed, I have already seen these rights on this file
  # [rw-r--r-- puppet:puppet] and I prefer [rw-r----- puppet:puppet].
  # This is not very critic because the parent directory
  # of this file has restrained Unix rights.
  #
  #   https://tickets.puppetlabs.com/browse/SERVER-906
  #
  # Of course, we don't manage the content of this file,
  # just the Unix rights. We don't manage the owner and
  # the group too because the owner can be root:root if
  # just the "puppet-agent" package is installed but will
  # be puppet:puppet if the "puppetserver" package is
  # installed.
  file { "/etc/puppetlabs/puppet/ssl/private_keys/${::fqdn}.pem":
    ensure => present,
    mode   => '0640',
  }

  service { 'puppet':
    ensure     => $ensure_value,
    enable     => $enable_value,
    hasrestart => true,
    hasstatus  => true,
  }

  case $cron {

    'per-day': {
      $ensure_cron = 'present'
      $weekday     = '*' # [i] See remark below.
    }

    'per-week': {
      $ensure_cron = 'present'
      $weekday     = fqdn_rand(7)
    }

    'disabled': {
      $ensure_cron = 'absent'
      $weekday     = undef # Value useless in this case.
    }

  }

  $cron_bin = '/usr/local/sbin/run-cron.puppet'

  file { $cron_bin:
    ensure => $ensure_cron,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    source => 'puppet:///modules/puppetagent/run-cron.puppet',
  }

  # [i]: if we change the cron from 'per-week' to 'per-day',
  # and if the cron task was already defined, the weekday
  # value will not be changed if its value is not defined in
  # the resource below. In other words, if weekday is not
  # defined below, the current value (if the cron already
  # exists) will be kept.
  cron { 'cron-puppet-run':
    ensure  => $ensure_cron,
    user    => 'root',
    command => $cron_bin,
    hour    => fqdn_rand(24),
    minute  => fqdn_rand(60),
    weekday => $weekday,
    require => File[$cron_bin],
  }

}



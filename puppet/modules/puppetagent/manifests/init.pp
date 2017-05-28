class puppetagent {

  include '::puppetagent::params'

  [
    $service_enabled,
    $runinterval,
    $server,
    $ca_server,
    $cron,
    $puppetconf_path,
    $manage_puppetconf,
    $dedicated_log,
    $ssldir,
    $bindir,
    $etcdir,
    $supported_distributions,
    # It's not a parameter but an internal value.
    $file_flag_puppet_cron,
    $dedicated_log_file,
    $reload_rsyslog_cmd,
  ] = Class['::puppetagent::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $ensure_dedicated_log = case $dedicated_log {
    true:    { 'file'   }
    default: { 'absent' }
  }

  file { '/etc/rsyslog.d/01-puppet-agent.conf':
    ensure  => $ensure_dedicated_log,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Package['puppet-agent'],
    notify  => Exec['restart-rsyslog-for-puppet-agent'],
    content => epp( 'puppetagent/rsyslog-01-puppet-agent.conf.epp',
                    {
                      'dedicated_log_file' => $dedicated_log_file,
                    }
                  ),
  }

  # It's probably a good idea to not manage the "rsyslog"
  # service in this present module.
  exec { 'restart-rsyslog-for-puppet-agent':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'service rsyslog restart',
    before      => Package['puppet-agent'],
    refreshonly => true,
  }

  file { '/etc/logrotate.d/puppet-agent':
    ensure  => $ensure_dedicated_log,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Package['puppet-agent'],
    content => epp( 'puppetagent/logrotate-puppet-agent.epp',
                    {
                      'reload_rsyslog_cmd' => $reload_rsyslog_cmd,
                      'dedicated_log_file' => $dedicated_log_file,
                    }
                  ),
  }

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

    file { $puppetconf_path:
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
  file { [ "${ssldir}",
           "${ssldir}/private_keys",
         ]:
    ensure  => directory,
    mode    => '0750',
    require => Service['puppet'],
  }
  file { "${ssldir}/private_keys/${::fqdn}.pem":
    ensure  => present,
    mode    => '0640',
    require => File["${ssldir}/private_keys"],
  }
  # It's just a hack because in some cases, in fact it's
  # probably only when the node is an autonomous
  # puppetserver, an empty file can be created by the
  # previous resource and it crashes the puppet server.
  exec { "rm-${::fqdn}.pem-if-empty":
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    command => "rm '${ssldir}/private_keys/${::fqdn}.pem'",
    unless  => "test -s '${ssldir}/private_keys/${::fqdn}.pem'",
    require => File["${ssldir}/private_keys/${::fqdn}.pem"],
  }
  ### End ot the TODO.

  service { 'puppet':
    ensure     => $ensure_value,
    enable     => $enable_value,
    hasrestart => true,
    hasstatus  => true,
  }

  # pxp-agent is not necessary. See:
  #
  #   https://groups.google.com/forum/#!topic/puppet-users/JfK2674Lbxo
  #
  service { 'pxp-agent':
    ensure     => stopped,
    enable     => false,
    hasrestart => true,
    hasstatus  => true,
    require    => Service['puppet'],
  }

  # seed for the fqdn_rand() function.
  $seed = 'cron-puppet-run'

  case $cron {

    'per-day': {
      $ensure_cron  = 'present'
      $cron_enabled = true
      $weekday      = '*' # [i] See remark below.
    }

    'per-week': {
      $ensure_cron  = 'present'
      $cron_enabled = true
      $weekday      = fqdn_rand(7, $seed)
    }

    'disabled': {
      $ensure_cron  = 'absent'
      $cron_enabled = false
      $weekday      = undef # Value useless in this case.
    }

  }

  $cron_bin = '/usr/local/sbin/cron-puppet-run.puppet'

  file { $cron_bin:
    ensure => $ensure_cron,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    content => epp( 'puppetagent/cron-puppet-run.puppet.epp',
                    {
                      'bindir'                => $bindir,
                      'file_flag_puppet_cron' => $file_flag_puppet_cron,
                    }
                  ),
  }

  file { '/usr/local/sbin/set-cron-puppet-run.puppet':
    ensure => $ensure_cron,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    content => epp( 'puppetagent/set-cron-puppet-run.puppet.epp',
                    {
                      'file_flag_puppet_cron' => $file_flag_puppet_cron,
                    }
                  ),
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
    hour    => fqdn_rand(24, $seed),
    minute  => fqdn_rand(60, $seed),
    weekday => $weekday,
    require => File[$cron_bin],
  }

  file { '/usr/local/sbin/upgrade-puppet-agent.puppet':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0750',
    content => epp( 'puppetagent/upgrade-puppet-agent.puppet.epp',
                    {
                      'cron_enabled'          => $cron_enabled,
                      'file_flag_puppet_cron' => $file_flag_puppet_cron,
                    }
                  ),
  }

}



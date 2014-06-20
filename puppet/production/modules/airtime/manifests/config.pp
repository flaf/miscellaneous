class airtime::config {

  require 'airtime::params'
  $port          = $airtime::params::port
  $postgre_pass  = $airtime::params::postgre_pass
  $rabbitmq_pass = $airtime::params::rabbitmq_pass
  $api_key       = $airtime::params::api_key

  file { '/etc/airtime/airtime.conf':
    owner   => 'www-data',
    group   => 'www-data',
    mode    => 640,
    ensure  => present,
    content => template('airtime/airtime.conf.erb'),
    notify  => Class['airtime::services'],
  }

  file { '/etc/airtime/api_client.cfg':
    owner   => 'pypo',
    group   => 'pypo',
    mode    => 640,
    ensure  => present,
    content => template('airtime/api_client.cfg.erb'),
    notify  => Class['airtime::services'],
  }

  file { '/etc/airtime/media-monitor.cfg':
    owner   => 'pypo',
    group   => 'pypo',
    mode    => 640,
    ensure  => present,
    content => template('airtime/media-monitor.cfg.erb'),
    notify  => Class['airtime::services'],
  }

  file { '/etc/airtime/pypo.cfg':
    owner   => 'pypo',
    group   => 'pypo',
    mode    => 640,
    ensure  => present,
    content => template('airtime/pypo.cfg.erb'),
    notify  => Class['airtime::services'],
  }

}



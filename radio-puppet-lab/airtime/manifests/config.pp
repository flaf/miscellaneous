class airtime::config {

  require 'airtime::params'
  $port = $airtime::params::port

  file { '/etc/airtime/airtime.conf':
    owner   => 'www-data',
    group   => 'www-data',
    mode    => 640,
    ensure  => present,
    content => template('airtime/airtime.conf.erb'),
    notify  => Class['airtime::services'],
  }

}



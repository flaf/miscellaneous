class airtime::apache2 {

  require 'airtime::params'
  $port = $airtime::params::port

  exec { 'disable default vhost':
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => 'a2dissite default',
    # Exec only if there is already the symlink.
    onlyif  => 'test -L /etc/apache2/sites-enabled/000-default',
    notify  => Service['apache2']
  }

  ->

  file { 'airtime vhost':
    path    => '/etc/apache2/sites-available/airtime-vhost.conf',
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    content => template('airtime/airtime-vhost.conf.erb'),
    notify  => Service['apache2']
  }

  ->

  exec { 'enable airtime vhost':
    path    => '/bin:/sbin:/usr/bin:/usr/sbin',
    command => 'a2ensite airtime-vhost.conf',
    # Exec only if there is no symlink.
    unless  => 'test -L /etc/apache2/sites-enabled/airtime-vhost.conf',
    notify  => Service['apache2']
  }

  ->

  file { '/etc/apache2/ports.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    content => template('airtime/ports.conf.erb'),
    notify  => Service['apache2']
  }

  ->

  service { 'apache2':
    ensure => running,
    hasstatus => true,
    hasrestart => true,
  }

}



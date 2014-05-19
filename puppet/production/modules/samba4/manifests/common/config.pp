class samba4::common::config {

  require 'samba4::common::params'
  $ntp_server = $samba4::common::params::ntp_server

  file { '/etc/hosts':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('samba4/hosts.erb'),
  }

  file { '/etc/default/grub':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('samba4/grub.erb'),
  }

  exec { 'update-grub':
    require     => File['/etc/default/grub'],
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    user        => 'root',
    command     => 'update-grub',
    refreshonly => true,
    subscribe   => File['/etc/default/grub'],
  }

  package { 'ntp':
    ensure => latest,
  }

  file { '/etc/ntp.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('samba4/ntp.conf.erb'),
    notify  => Service['ntp'],
  }

  service { 'ntp':
    require => File['/etc/ntp.conf'],
    ensure  => running,
  }

}



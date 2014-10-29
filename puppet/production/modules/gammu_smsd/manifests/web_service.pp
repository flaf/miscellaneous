# Class: gammu_smsd::web_service
#
# This is an internal class.
#
class gammu_smsd::web_service {

  require '::gammu_smsd'

  $limit_access = $::gammu_smsd:limit_access

  if ! defined(Package['libapache2-mod-perl2']) {
    package { 'libapache2-mod-perl2':
      ensure => present,
    }
  }

  file { '/var/spool/gammu/outbox':
    owner   => 'gammu',
    group   => 'www-data',
    mode    => '770',
    require => Package['libapache2-mod-perl2'],
  }

  file { '/usr/lib/cgi-bin/sendsms.pl':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0755,
    source  => "puppet:///modules/${module_name}/sendsms.pl",
    require => Package['libapache2-mod-perl2'],
    notify  => Service['apache2'],
  }

  file { '/etc/apache2/envvars':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 0644,
    source  => "puppet:///modules/${module_name}/envvars",
    require => Package['libapache2-mod-perl2'],
    notify  => Service['apache2'],
  }

  exec { 'disable default vhost':
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    command => 'a2dissite default',
    # Exec only if there is already the symlink.
    onlyif  => 'test -L /etc/apache2/sites-enabled/000-default',
    require => Package['libapache2-mod-perl2'],
    notify  => Service['apache2'],
  }

  file { 'sms vhost':
    path    => '/etc/apache2/sites-available/sms_vhost',
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    content => template("${module_name}/sms_vhost.erb"),
    require => Package['libapache2-mod-perl2'],
    notify  => Service['apache2'],
  }

  exec { 'enable sms vhost':
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    command => 'a2ensite sms_vhost',
    # Exec unless there is already the symlink.
    unless  => 'test -L /etc/apache2/sites-enabled/sms_vhost',
    require => File['sms vhost'],
    notify  => Service['apache2'],
  }

  service { 'apache2':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    require    => Package['libapache2-mod-perl2'],
  }

}


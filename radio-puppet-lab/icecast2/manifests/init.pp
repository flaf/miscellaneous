class icecast2 {

  require 'icecast2::params'

  $git_repository        = $icecast2::params::git_repository
  $git_directory         = $icecast2::params::git_directory
  $git_lockfile          = $icecast2::params::git_lockfile
  $mountpoints_file      = $icecast2::params::mountpoints_file
  $admins_mails          = $icecast2::params::admins_mails
  $source_password       = $icecast2::params::source_password
  $admin_password        = $icecast2::params::admin_password
  $port                  = $icecast2::params::port
  $limits_clients        = $icecast2::params::limits_clients
  $limits_sources        = $icecast2::params::limits_sources
  $limits_source_timeout = $icecast2::params::limits_source_timeout
  $log_level             = $icecast2::params::log_level
  $log_size              = $icecast2::params::log_size

  if ($git_repository != '') {
    include 'icecast2::gitrepository'
  }

  package { 'icecast2':
    ensure => present,
    notify => Service['icecast2'],
  }

  ->

  file { '/etc/icecast2/icecast.xml.puppet':
    ensure  => present,
    owner   => 'icecast2',
    group   => 'icecast',
    mode    => 660,
    content => template('icecast2/icecast.xml.puppet.erb'),
    notify  => Service['icecast2'],
  }

  ->

  file { '/etc/default/icecast2':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    content => template('icecast2/icecast2.default.erb'),
    notify  => Service['icecast2'],
  }

  ->

  file { '/usr/local/bin/print_mountpoints':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 755,
    content => template('icecast2/print_mountpoints.erb'),
  }

  ->

  file { '/usr/local/sbin/icecast-service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 755,
    content => template('icecast2/icecast-service.erb'),
  }

  ->

  exec { 'update-icecast-conf':
    user    => 'root',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    command => '/usr/local/sbin/icecast-service update-conf',
    unless  => '/usr/local/sbin/icecast-service is-updated',
    notify  => Service['icecast2'],
  }

  ->

  service { 'icecast2':
    # The return value of The icecast2 init script is false.
    # Must use a specific script to start/restart/status.
    hasrestart => false,
    hasstatus  => false,
    status     => '/usr/local/sbin/icecast-service status',
    start      => '/usr/local/sbin/icecast-service start',
    restart    => '/usr/local/sbin/icecast-service restart',
    ensure     => running,
  }

}



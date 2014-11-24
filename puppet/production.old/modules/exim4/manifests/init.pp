class exim4 {

  $smtp_passwd = extlookup("smtp_passwd")

  package { ['exim4', 'heirloom-mailx']:
    ensure => latest,
    notify => Exec['update-exim4'],
  }

  ->

  file { '/etc/exim4/update-exim4.conf.conf':
    ensure  => present,
    content => template('exim4/update-exim4.conf.erb'),
    notify  => Exec['update-exim4'],
  }

  ->

  file { '/etc/exim4/passwd.client':
    ensure  => present,
    content => template('exim4/passwd.client.erb'),
    notify  => Exec['update-exim4'],
  }

  ->

  exec { 'update-exim4':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'update-exim4.conf',
    refreshonly => true,
    notify      => Service['exim4'],
  }

  ->

  service { 'exim4':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }

}



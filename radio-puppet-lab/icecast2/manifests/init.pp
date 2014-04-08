class icecast2 {

  package { 'icecast2':
    ensure => present,
  }

  file { '/etc/icecast2/icecast.xml.puppet':
    ensure  => present,
    owner   => 'icecast2',
    group   => 'icecast',
    mode    => 660,
    content => template('icecast2/icecast.xml.puppet.erb'),
    require => Package['icecast2'],
    notify  => Service['icecast2'],
  }

  file { '/etc/default/icecast2':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => 644,
    content => template('icecast2/icecast2.default.erb'),
    require => Package['icecast2'],
    notify  => Service['icecast2'],
  }

  service { 'icecast2':
    hasrestart => true,
    hasstatus  => false,
    ensure     => running,
  }

}



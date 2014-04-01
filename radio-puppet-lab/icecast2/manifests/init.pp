class icecast2 {

  package { 'icecast2':
    ensure => present,
  }

  service { 'icecast2':
    hasrestart => true,
    ensure     => running,
    require    => Package['icecast2'],
  }

}



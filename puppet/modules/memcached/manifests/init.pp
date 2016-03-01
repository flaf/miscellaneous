class memcached (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::memcached::params']) { include '::memcached::params' }
  $memory = $::memcached::params::memory

  ensure_packages( [ 'memcached' ], { ensure => present } )

  file_line { 'edit-memcached-memory':
    path    => '/etc/memcached.conf',
    line    => "-m ${memory} # Edited by Puppet.",
    match   => '^-m[[:space:]]+[0-9]+.*$',
    require => Package['memcached'],
    notify  => Service['memcached'],
  }

  # We need to comment the line /-l 127.0.0.1/, else
  # memcached listens only to localhost.
  file_line { 'edit-memcached-listening':
    path    => '/etc/memcached.conf',
    line    => "#-l 127.0.0.1 # Edited by Puppet.",
    match   => '^#?-l[[:space:]]+.*$',
    require => Package['memcached'],
    notify  => Service['memcached'],
  }

  service { 'memcached':
    ensure     => running,
    hasrestart => true,
  }

}



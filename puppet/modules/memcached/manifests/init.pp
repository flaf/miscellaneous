class memcached (
  Integer[1]          $memory,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ensure_packages( [ 'memcached' ], { ensure => present } )

  file_line { 'edit-memcached-memory':
    path    => '/etc/memcached.conf',
    line    => "-m ${memory} # Edited by Puppet.",
    match   => '^-m[[:space:]]+[0-9]+.*$',
    require => Package['memcached'],
    notify  => Service['memcached'],
  }

  service { 'memcached':
    ensure     => running,
    hasrestart => true,
  }

}



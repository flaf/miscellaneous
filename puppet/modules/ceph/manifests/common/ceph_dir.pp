class ceph::basis {

  ensure_packages( [ 'ceph' ], { ensure => present, } )

  file { '/etc/ceph':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    require => Package['ceph'],
  }

}



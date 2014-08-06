class ceph_lab {

  # Python 2.7 must be installed.
  package { 'python':
    ensure => present,
  }

  # xfs is needed for the storage fs.
  package { 'xfsprogs':
    ensure => present,
  }

  file { '/usr/local/sbin/Ceph_ready':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => 755,
    source => 'puppet:///modules/ceph_lab/Ceph_ready',
  }

  file { '/usr/local/sbin/Ceph_create_user':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => 755,
    source => 'puppet:///modules/ceph_lab/Ceph_create_user',
  }

  file { '/usr/local/sbin/Ceph_mon_bootstrapping':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => 755,
    source => 'puppet:///modules/ceph_lab/Ceph_mon_bootstrapping',
  }

}



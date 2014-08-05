class ceph_lab {

  # Python 2.7 must be installed.
  package { 'python':
    ensure => present,
  }

  file { '/usr/local/sbin/Ceph_ready':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => 755,
    source => 'puppet:///modules/ceph_lab/Ceph_ready',
  }

}



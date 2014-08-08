class ceph_lab {

  # Python 2.7 must be installed.
  package { 'python':
    ensure => present,
  }

  # xfs is needed for the storage fs.
  package { 'xfsprogs':
    ensure => present,
  }

  define tools() {
    file { $name:
      ensure => present,
      path   => "/usr/local/sbin/${name}",
      owner  => 'root',
      group  => 'root',
      mode   => 755,
      source => "puppet:///modules/ceph_lab/${name}",
    }
  }

  $tools = [ 'Ceph_ready',
             'Ceph_install',
             'Ceph_create_user',
             'Ceph_mon_bootstrapping',
             'Ceph_add_osd',
             'Ceph_add_osd_v2',
             'Ceph_add_mon',
             'Ceph_remove_osd',
           ]

  tools { $tools: }

}



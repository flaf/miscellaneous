class ceph_lab {

  include '::apt'

  # Python 2.7 must be installed.
  if ! defined(Package['python']) {
    package { 'python':
      ensure => present,
    }
  }

  # xfs is needed for the storage fs.
  if ! defined(Package['xfsprogs']) {
    package { 'xfsprogs':
      ensure => present,
    }
  }

  $ceph_release = "firefly"

  apt::source { 'ceph':
    location    => "http://ceph.com/debian-${ceph_release}/",
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => '17ED316D',
    include_src => false,
  }

  if ! defined(Package['ceph']) {
    package { 'ceph':
      ensure  => present,
      require => Apt::Source['ceph'],
    }
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
             'Ceph_pick_conf',
             'Ceph_create_user',
             'Ceph_mon_bootstrapping',
             'Ceph_add_osd',
             'Ceph_add_osd_v2',
             'Ceph_add_mon',
             'Ceph_mds_install',
             'Ceph_remove_osd',
             'Ceph_create_rados_block_device',
             'Ceph_grep_process',
             'Ceph_restart_all',
             'Ceph_status',
             'Ceph_mount',
           ]

  tools { $tools: }

}



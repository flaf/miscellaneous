class ceph::cluster::scripts {

  file { '/usr/local/share/ceph':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
  }

  $ceph_script_common = '/usr/local/share/ceph/ceph-common.sh'

  file { $ceph_script_common:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('ceph/ceph-common.sh.epp',
                   { 'ceph_script_common' => $ceph_script_common, }
                  ),
  }

  file { '/usr/local/sbin/ceph-monitor-init':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => epp('ceph/ceph-monitor-init.epp',
                   { 'ceph_script_common' => $ceph_script_common, }
                  ),
  }

  file { '/usr/local/sbin/ceph-monitor-add':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => epp('ceph/ceph-monitor-add.epp',
                   { 'ceph_script_common' => $ceph_script_common, }
                  ),
  }

  file { '/usr/local/sbin/ceph-osd-add':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => epp('ceph/ceph-osd-add.epp',
                   { 'ceph_script_common' => $ceph_script_common, }
                  ),
  }

  file { '/usr/local/sbin/ceph-mds-add':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => epp('ceph/ceph-mds-add.epp',
                   { 'ceph_script_common' => $ceph_script_common, }
                  ),
  }

}



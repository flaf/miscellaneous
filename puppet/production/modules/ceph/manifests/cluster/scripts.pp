#
# Private class.
#
class ceph::cluster::scripts {

  private("Sorry, ${title} is a private class.")

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
    content => template('ceph/ceph-common.sh.erb'),
  }

  file { '/usr/local/sbin/ceph-monitor-init':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('ceph/ceph-monitor-init.erb'),
  }

  file { '/usr/local/sbin/ceph-monitor-add':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('ceph/ceph-monitor-add.erb'),
  }

  file { '/usr/local/sbin/ceph-osd-add':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('ceph/ceph-osd-add.erb'),
  }

  file { '/usr/local/sbin/ceph-mds-add':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('ceph/ceph-mds-add.erb'),
  }

}



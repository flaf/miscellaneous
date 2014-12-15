#
# Private class.
#
class ceph::scripts {

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

  $ceph_script_common = '/usr/local/share/ceph/ceph_common.sh'

  file { $ceph_script_common:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ceph/ceph_common.sh.erb'),
  }

  file { '/usr/local/sbin/ceph_monitor_init':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('ceph/ceph_monitor_init.erb'),
  }

  file { '/usr/local/sbin/ceph_monitor_add':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('ceph/ceph_monitor_add.erb'),
  }

  file { '/usr/local/sbin/ceph_osd_add':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('ceph/ceph_osd_add.erb'),
  }

}



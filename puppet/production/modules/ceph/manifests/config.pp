#
# Private class.
#
class ceph::config {

  private("Sorry, ${title} is a private class.")

  file { "/etc/ceph/${::ceph::cluster_name}.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ceph/ceph.conf.erb'),
  }

  file { "/etc/ceph/${::ceph::cluster_name}.client.admin.keyring":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => template('ceph/ceph.client.admin.keyring.erb'),
  }

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

  file { $::ceph::monitor_init_cmd:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('ceph/ceph_monitor_init.erb'),
  }

  file { $::ceph::monitor_add_cmd:
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



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

}



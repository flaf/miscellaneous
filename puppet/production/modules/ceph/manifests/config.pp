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

}



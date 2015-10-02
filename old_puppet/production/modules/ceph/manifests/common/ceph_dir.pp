#
# Private class.
#
class ceph::common::ceph_dir {

  private("Sorry, ${title} is a private class.")

  file { '/etc/ceph':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
  }

}



#
# This is a private class.
#
class ceph::osds {

  private("Sorry, ${title} is a private class.")

  $osd_add_cmd = '/usr/local/sbin/osd_add'

  file { $osd_add_cmd:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('ceph/osd_add.erb'),
  }

}



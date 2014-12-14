#
# This is a private class.
#
class ceph::monitor_init {

  private("Sorry, ${title} is a private class.")

  $monitor_init_cmd = '/usr/local/sbin/ceph_monitor_init'

  file { $monitor_init_cmd:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('ceph/ceph_monitor_init.erb'),
    before  => Exec['monitor-initialization'],
  }

  exec { 'monitor-initialization':
    command => $monitor_init_cmd,
    user    => 'root',
    group   => 'root',
    onlyif  => "$monitor_init_cmd --test",
  }

}



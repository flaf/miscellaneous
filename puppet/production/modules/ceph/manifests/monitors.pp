#
# This is a private class.
#
class ceph::monitors {

  private("Sorry, ${title} is a private class.")

  $monitor_add_cmd = '/usr/local/sbin/monitor_add'

  file { $monitor_add_cmd:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    content => template('ceph/monitor_add.erb'),
    before  => Exec['monitor-add'],
  }

  exec { 'monitor-add':
    command => $monitor_add_cmd,
    user    => 'root',
    group   => 'root',
    onlyif  => "$monitor_add_cmd --test",
  }

}



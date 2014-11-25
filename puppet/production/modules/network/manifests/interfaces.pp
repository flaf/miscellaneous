class network::interfaces (
  $stage      = 'network',
  $interfaces,
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Module `${module_name}` is not supported or not yet tested on ${::lsbdistcodename}.")
    }
  }

  file { '/etc/udev/rules.d/10-interfaces.rules':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('network/10-interfaces.rules.erb'),
  }

  file { '/usr/local/sbin/network-restart':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0754',
    source => "puppet:///modules/network/network-restart"
  }

}


class network::interfaces (
  $stage           = 'network',
  $restart_network = false,
  $interfaces,
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Module `${module_name}` is not supported or not yet tested on ${::lsbdistcodename}.")
    }
  }

  file { '/etc/udev/rules.d/70-persistent-net.rules':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('network/70-persistent-net.rules.erb'),
  }

  file { '/etc/network/interfaces.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('network/interfaces.puppet.erb'),
  }

  file { '/usr/local/sbin/network-restart':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0754',
    source => "puppet:///modules/network/network-restart",
  }

  if $restart_network {
    exec { 'network-restart':
      command     => '/usr/local/sbin/network-restart',
      user        => 'root',
      group       => 'root',
      refreshonly => true,
      require     => File['/usr/local/sbin/network-restart'],
      subscribe   => [
                       File['/etc/udev/rules.d/70-persistent-net.rules'],
                       File['/etc/network/interfaces.puppet'],
                     ],
    }
  }

}


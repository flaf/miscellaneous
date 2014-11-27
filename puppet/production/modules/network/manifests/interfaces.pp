class network::interfaces (
  $stage           = 'network',
  $restart_network = false,
  $interfaces,
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  # To make uniform between Wheezy and Trusty.
  # Trusty uses resolvconf by default but not Wheezy.
  # And it's not recommended to remove resolvconf
  # in Trusty (if you do that, you will remove the
  # "ubuntu-minimal" package that is not recommended).
  if ! defined(Package['resolvconf']) {
    package { 'resolvconf':
      ensure => present,
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


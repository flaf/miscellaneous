class network::interfaces (
  $stage           = 'network',
  $meta_options    = [
                       'macaddress',
                       'vlan_name',
                       'vlan_id',
                       'comment',
                     ],
  $force_ifnames   = false,
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

  $a =  {
          "eth0" => {
                      "macaddress" => "08:00:27:bc:cf:03",
                      "method"     =>"dhcp"
                    },
          "eth1" => { "macaddress" => "08:00:27:bc:cf:04",
                      "method"     => "static",
                      "address"    => "172.30.240.12/20",
                      "netmask"    => "255.0.0.0",
                      #"network"    => "10.0.7.0",
                    },
           }


  $interfaces_filled = fill_ifhash($interfaces)

  notify { 'test':
    message => "\n\n $interfaces_filled \n\n"
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

  if $force_ifnames {
    $content_rule = template('network/70-persistent-net.rules.erb')
    $replace_rule = true
  } else {
    $content_rule = "# Empty file created by Puppet because no interface renaming.\n"
    $replace_rule = false
  }

  file { '/etc/udev/rules.d/70-persistent-net.rules':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    replace => $replace_rule,
    content => $content_rule,
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


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

  # Checking of parameters.
  unless is_string($stage) {
    fail("In the ${title} class, `stage` parameter must be a string.")
  }

  if empty($stage) {
    fail("In the ${tilte} class, `stage` parameter must not be empty.")
  }

  unless is_array($meta_options) {
    fail("In the ${title} class, `meta_options` parameter must be an array.")
  }

  unless is_bool($force_ifnames) {
    fail("In the ${title} class, `force_ifnames` parameter must be a boolean.")
  }

  unless is_bool($restart_network) {
    fail("In the ${title} class, `restart_network` parameter must be a boolean.")
  }

  unless is_hash($interfaces) {
    fail("In the ${title} class, `interfaces` parameter must be a hash.")
  }

  if empty($interfaces) {
    fail("In the ${tilte} class, `interfaces` parameter must not be empty.")
  }

  #------------------------------------------------------
  $a =  {
          "em0"  => {
                      "titi" => "toto",
                    },
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

  $interfaces_filled = fill_ifhash($a)

  notify { 'test':
    message => "\n\n $interfaces_filled \n\n"
  }
  #------------------------------------------------------

  #$interfaces_filled = fill_ifhash($interfaces)

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


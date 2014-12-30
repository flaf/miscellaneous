class roles::test {

  #include '::profiles::hosts::generic'

  $ht = hiera('hosts_entries')

  ::hosts::entry { 'self':
    address   => $ht['self']['address'],
    hostnames => $ht['self']['hostnames'],
    exported  => true,
    tag       => 'test',
  }

  #::hosts::entry { 'google':
  #  address   => '8.8.8.8',
  #  hostnames => [ 'google' ],
  #  exported  => true,
  #  tag       => 'test',
  #}

  class { '::hosts::collect':
    tag => 'test',
  }

  include '::profiles::network::generic'
  include '::profiles::timezone::generic'
  include '::profiles::locales::generic'
  include '::profiles::keyboard::generic'
  include '::profiles::apt::generic'
  include '::profiles::ntp::generic'
  include '::profiles::grub::generic'
  include '::profiles::puppet::generic'
  include '::profiles::ssh::generic'
  include '::profiles::misc::generic'

}



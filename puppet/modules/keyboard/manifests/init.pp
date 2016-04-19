class keyboard {

  include '::keyboard::params'

  $xkbmodel   = $::keyboard::params::xkbmodel
  $xkblayout  = $::keyboard::params::xkblayout
  $xkbvariant = $::keyboard::params::xkbvariant
  $xkboptions = $::keyboard::params::xkboptions
  $backspace  = $::keyboard::params::backspace

  $conf_hash = {
    'xkbmodel'   => $xkbmodel,
    'xkblayout'  => $xkblayout,
    'xkbvariant' => $xkbvariant,
    'xkboptions' => $xkboptions,
    'backspace'  => $backspace,
  }

  file { '/etc/default/keyboard':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('keyboard/default.keyboard.epp', $conf_hash),
  }

  case $::lsbdistcodename {
    'trusty': {
      $command = 'dpkg-reconfigure --frontend=noninteractive keyboard-configuration'
    }
    default: {
      # With Wheezy, it's was the same too.
      $command = 'service keyboard-setup restart'
    }
  }

  exec { 'update-keyboard-conf':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => $command,
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    require     => File['/etc/default/keyboard'],
    subscribe   => File['/etc/default/keyboard'],
  }

}



class keyboard {

  include '::keyboard::params'

  [
    $xkbmodel,
    $xkblayout,
    $xkbvariant,
    $xkboptions,
    $backspace,
    $supported_distributions,
  ] = Class['::keyboard::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

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
    'jessie': {
      # With Wheezy it's was the same command too.
      $command = 'service keyboard-setup restart'
    }
    # Currently, this command is OK for Ubuntu distributions
    # supported by this module.
    default: {
      $command = 'dpkg-reconfigure --frontend=noninteractive keyboard-configuration'
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



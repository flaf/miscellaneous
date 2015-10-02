class keyboard (
  String[1] $xkbmodel,
  String[1] $xkblayout,
  String[1] $xkbvariant,
  String    $xkboptions,
  String[1] $backspace,
  Array[String[1], 1] $supported_distributions,
) {

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



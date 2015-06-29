class keyboard (
  String[1] $xkbmodel   = 'pc105',
  String[1] $xkblayout  = 'fr',
  String[1] $xkbvariant = 'latin9',
  String    $xkboptions = '',
  String[1] $backspace  = 'guess',
) {

  ::homemade::is_supported_distrib(['trusty'], $title)

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

  # With Wheezy, it's was => service keyboard-setup restart
  $command = 'dpkg-reconfigure --frontend=noninteractive keyboard-configuration'

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



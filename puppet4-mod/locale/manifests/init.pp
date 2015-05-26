class locale (
  Enum['en_US.UTF-8', 'fr_FR.utf8'] $default_locale = 'en_US.UTF-8',
) {

  is_supported_distrib(['trusty'], $title)

  file { '/etc/default/locale':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "LANG=${default_locale}\n",
  }

  # In fact, this is the opposite. The command below
  # updates the default locale and write in the
  # '/etc/default/locale' file. But, in this case,
  # the file is a good way to know if the default
  # locale is set as we want.
  exec { 'update-default-locale':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => "update-locale LANG='${default_locale}'",
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    require     => File['/etc/default/locale'],
    subscribe   => File['/etc/default/locale'],
  }

}



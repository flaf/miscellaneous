class timezone (
  Enum['Etc/UTC', 'Europe/Paris'] $timezone = 'Etc/UTC',
) {

  ::homemade::is_supported_distrib(['trusty'], $title)

  file { '/etc/timezone':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "${timezone}\n",
  }

  exec { 'reconfigure-timezone':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'dpkg-reconfigure --frontend="noninteractive" tzdata',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    require     => File['/etc/timezone'],
    subscribe   => File['/etc/timezone'],
  }

}



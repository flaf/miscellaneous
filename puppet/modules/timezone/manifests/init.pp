class timezone (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::timezone::params']) {
    include '::timezone::params'
  }

  $timezone = $::timezone::params::timezone

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



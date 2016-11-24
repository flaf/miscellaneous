class timezone {

  include '::timezone::params'

  [
    $timezone,
    $supported_distributions,
  ] = Class['::timezone::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  file { '/etc/timezone':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "${timezone}\n",
  }

  if $::facts['os']['distro']['codename'] == 'xenial' {

    exec { 'set-symlink-localtime':
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      command => "ln -fs /usr/share/zoneinfo/${timezone} /etc/localtime",
      user    => 'root',
      group   => 'root',
      # Don't use "readlink -f" here because, for instance,
      # /usr/share/zoneinfo/Etc/UTC is a symlink to
      # "../Universal". So "readlink -f /etc/localtime" can
      # print "/usr/share/zoneinfo/Universal" instead of the
      # expected "/usr/share/zoneinfo/Etc/UTC". So we use
      # the readlink command but without the -f option.
      unless  => "test $(readlink /etc/localtime) = '/usr/share/zoneinfo/${timezone}'",
      require => File['/etc/timezone'],
      notify  => Exec['reconfigure-timezone'],
    }

  }

  exec { 'reconfigure-timezone':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'dpkg-reconfigure --frontend="noninteractive" tzdata',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    subscribe   => File['/etc/timezone'],
  }

}



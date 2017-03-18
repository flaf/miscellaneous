class locale {

  include '::locale::params'

  [
    $default_locale,
    $supported_distributions,
  ] = Class['::locale::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

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



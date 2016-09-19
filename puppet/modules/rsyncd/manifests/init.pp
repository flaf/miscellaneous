class rsyncd {

  include '::rsyncd::params'

  [
    $modules,
    $users,
    $secret_file,
    $supported_distributions,
  ] = Class['::rsyncd::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)
  ::rsyncd::check_params($modules, $users, $title)

  ensure_packages(['rsync'], { ensure => present })

  file_line { 'edit-etc-default-rsync':
    path    => '/etc/default/rsync',
    line    => 'RSYNC_ENABLE=true # Line edited by Puppet, do not touch it.',
    match   => '^RSYNC_ENABLE=.*$',
    require => Package['rsync'],
    notify  => Service['rsync'],
  }

  file { '/etc/rsyncd.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['rsync'],
    notify  => Service['rsync'],
    content => epp('rsyncd/rsyncd.conf.epp',
                   {
                     'modules'     => $modules,
                     'secret_file' => $secret_file,
                   }
                  ),
  }

  $ensure_secret_file = $users.empty ? {
    true  => 'absent',
    false => 'present',
  }

  file { $secret_file:
    ensure  => $ensure_secret_file,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Package['rsync'],
    notify  => Service['rsync'],
    content => epp('rsyncd/rsyncd.secret.epp', { 'users' => $users }),
  }

  service { 'rsync':
    ensure     => running,
    hasrestart => true,
  }

}



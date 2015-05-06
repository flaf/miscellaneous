class mcollective::server (
  $server_private_key,
  $server_public_key,
) {

  $packages = [
               'ruby-stomp',
               'mcollective',
              ]

  ensure_packages($packages, { ensure => present, })

  $server_private_key_file = '/etc/mcollective/ssl/server-private.pem'
  $server_public_key_file  = '/etc/mcollective/ssl/server-public.pem'

  file { $server_private_key_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $server_private_key,
    require => Package['mcollective'],
  }

  file { $server_public_key_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $server_public_key,
    require => Package['mcollective'],
  }

  file { '/etc/mcollective/server.cfg':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('mcollective/server.cfg.erb'),
  #  require => Package['mcollective'],
  #  before  => Service['mcollective'],
  #  notify  => Service['mcollective'],
  }

  #service { 'mcollective':
  #  ensure     => running,
  #  hasstatus  => true,
  #  hasrestart => true,
  #}

}



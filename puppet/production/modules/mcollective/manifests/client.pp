class mcollective::client (
  $server_public_key,
  $client_private_key,
  $client_public_key,
  $middleware_server,
  $middleware_port,
  $mcollective_pwd,
  $ssl_dir = '/var/lib/puppet/ssl',
) {

  $packages = [
               'mcollective-client',
               'mcollective-shell-client',
              ]

  ensure_packages($packages, { ensure => present, })

  $server_public_key_file  = '/etc/mcollective/ssl/server-public.pem'
  $client_private_key_file = "/etc/mcollective/ssl/${::fqdn}.pem"
  $client_public_key_file  = "/etc/mcollective/ssl/${::fqdn}.pem"

  # If the host is server and client mcollective, we must manage
  # this resource just once. The server public key is needed for
  # the client in order to crypt message.
  if ! defined(File[$server_public_key_file]) {
    file { $server_public_key_file:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0600',
      content => $server_public_key,
    }
  }

  file { $client_private_key_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $client_private_key,
    require => Package['mcollective-client'],
  }

  file { $client_public_key_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $client_public_key,
    require => Package['mcollective-client'],
  }

  file { '/etc/mcollective/client.cfg':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => template('mcollective/client.cfg.erb'),
  }

}


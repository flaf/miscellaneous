class mcollective::client (
  String[1]                    $client_private_key,
  String[1]                    $client_public_key,
  String[1]                    $mco_tag,
  Enum['rabbitmq', 'activemq'] $connector,
  String[1]                    $middleware_server,
  Integer[1]                   $middleware_port,
  String[1]                    $mcollective_pwd,
  String[1]                    $puppet_ssl_dir,
  Array[String[1], 1]          $supported_distributions,
) {

  # We assume that a client is necessarily a mcollective server.
  require '::mcollective::server'

  $mco_ssl_dir             = '/etc/puppetlabs/mcollective/ssl'
  $client_private_key_file = "${mco_ssl_dir}/clients/${::fqdn}.priv.pem"
  $client_public_key_file  = "${mco_ssl_dir}/clients/${::fqdn}.pub.pem"
  $server_public_key_file  = "${mco_ssl_dir}/server-public.pem"

  file { $client_private_key_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $client_private_key,
  }

  @@file { $client_public_key_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $client_public_key,
    tag     => $mco_tag,
  }

  file { '/etc/puppetlabs/mcollective/client.cfg':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp( 'mcollective/client.cfg.epp',
                    { 'server_public_key_file'  => $server_public_key_file,
                      'client_public_key_file'  => $client_public_key_file,
                      'client_private_key_file' => $client_private_key_file,
                      'connector'               => $connector,
                      'middleware_server'       => $middleware_server,
                      'middleware_port'         => $middleware_port,
                      'mcollective_pwd'         => $mcollective_pwd,
                      'puppet_ssl_dir'          => $puppet_ssl_dir,
                    }
                  ),
  }

}



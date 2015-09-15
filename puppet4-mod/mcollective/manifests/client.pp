class mcollective::client (
  String[1]                    $client_private_key,
  String[1]                    $client_public_key,
  String[1]                    $mco_tag,
  Enum['rabbitmq', 'activemq'] $connector,
  String[1]                    $middleware_server,
  Integer[1]                   $middleware_port,
  String[1]                    $mcollective_pwd,
  String[1]                    $puppet_ssl_dir,
  String[1]                    $mco_client_keys_dir,
  Array[String[1], 1]          $supported_distributions,
) {

  require '::mcollective::package'

  $client_private_key_file = "${mco_client_keys_dir}/${::fqdn}.priv.pem"
  $client_public_key_file  = "${mco_client_keys_dir}/${::fqdn}.pub.pem"
  $server_public_key_file  = "${mco_client_keys_dir}/server-public-key.pem"

  file { $puppet_ssl_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0500',
    recurse => true,
    purge   => true,
  }

  file { $client_private_key_file:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $client_private_key,
  }

  # This key must be exported for the mcollective servers.
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



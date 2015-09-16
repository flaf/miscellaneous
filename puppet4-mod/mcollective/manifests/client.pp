class mcollective::client (
  String[1]                    $client_private_key,
  String[1]                    $client_public_key,
  String[1]                    $server_public_key,
  String[1]                    $mco_tag,
  Enum['rabbitmq', 'activemq'] $connector,
  String[1]                    $middleware_server,
  Integer[1]                   $middleware_port,
  String[1]                    $mcollective_pwd,
  String[1]                    $puppet_ssl_dir,
  Array[String[1], 1]          $supported_distributions,
) {

  require '::mcollective::package'

  # Just shortcuts.
  $client_keys_dir     = $::mcollective::package::client_keys_dir
  $allowed_clients_dir = $::mcollective::package::allowed_clients_dir

  # Paths of important files.
  $client_priv_key_path    = "${client_keys_dir}/${::fqdn}.priv-key.pem"
  $client_pub_key_path     = "${client_keys_dir}/${::fqdn}.pub-key.pem"
  $client_pub_key_path_exp = "${allowed_clients_dir}/${::fqdn}.pub-key.pem"
  $server_pub_key_path     = "${client_keys_dir}/servers-pub-key.pem"

  # mcollective::client and mcollective::server will manage this
  # directory because the client keys are very sensitive. If a
  # node is no longer a mcollective client, we want to remove the
  # client keys (especially the client private key).
  if !defined(File[$client_keys_dir]) {
    file { $client_keys_dir:
      ensure  => directory,
      owner   => 'root',
      group   => 'root',
      mode    => '0500',
      recurse => true,
      purge   => true,
    }
  }

  file { $client_priv_key_path:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $client_private_key,
  }

  # This key must be exported for the mcollective servers
  # but in a different path. So we just export another
  # resource (the resource just after) with the new path
  # and the same content.
  file { $client_pub_key_path:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $client_public_key,
  }

  # The same resource as above but with a different path.
  @@file { $client_pub_key_path_exp:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $client_public_key,
    tag     => $mco_tag,
  }

  file { $server_pub_key_path:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $server_public_key,
  }

  file { '/etc/puppetlabs/mcollective/client.cfg':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0640',
    content => epp( 'mcollective/client.cfg.epp',
                    { 'server_pub_key_path'  => $server_pub_key_path,
                      'client_pub_key_path'  => $client_pub_key_path,
                      'client_priv_key_path' => $client_priv_key_path,
                      'connector'            => $connector,
                      'middleware_server'    => $middleware_server,
                      'middleware_port'      => $middleware_port,
                      'mcollective_pwd'      => $mcollective_pwd,
                      'puppet_ssl_dir'       => $puppet_ssl_dir,
                    }
                  ),
  }

}



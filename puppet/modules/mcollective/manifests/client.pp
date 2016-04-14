class mcollective::client (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  require '::mcollective::package'
  require '::repository::mco'
  include '::mcollective::client::params'

  $translation = {
    'collectives'             => '::mcollective::client::params::collectives',
    'client_private_key'      => '::mcollective::client::params::private_key',
    'client_public_key'       => '::mcollective::client::params::public_key',
    'server_public_key'       => '::mcollective::client::params::server_public_key',
    'connector'               => '::mcollective::client::params::connector',
    'middleware_address'      => '::mcollective::client::params::middleware_address',
    'middleware_port'         => '::mcollective::client::params::middleware_port',
    'mcollective_pwd'         => '::mcollective::client::params::mcollective_pwd',
    'mco_tag'                 => '::mcollective::client::params::mco_tag',
    'puppet_ssl_dir'          => '::mcollective::client::params::puppet_ssl_dir',

    'client_keys_dir'         => '::mcollective::package::client_keys_dir',
    'allowed_clients_dir'     => '::mcollective::package::allowed_clients_dir',
    'client_priv_key_path'    => '::mcollective::package::client_priv_key_path',
    'client_pub_key_path'     => '::mcollective::package::client_pub_key_path',
    'client_pub_key_path_exp' => '::mcollective::package::client_pub_key_path_exp',
  }

  $params_tmp = ::homemade::varname2value($translation, $title)
  $params     = $params_tmp + {
    'server_pub_key_path' => "${params_tmp['client_keys_dir']}/servers-pub-key.pem",
    'collectives'         => $params_tmp['collectives'].unique.sort,
  }

  [
    $collectives,
    $client_private_key,
    $client_public_key,
    $server_public_key,
    $connector,
    $middleware_address,
    $middleware_port,
    $mcollective_pwd,
    $mco_tag,
    $puppet_ssl_dir,
    $client_keys_dir,
    $allowed_clients_dir,
    $client_priv_key_path,
    $client_pub_key_path,
    $client_pub_key_path_exp,
    $server_pub_key_path,
  ] = $params

  ensure_packages(['mcollective-flaf-clients'], { ensure => present, })

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
                    {
                      'collectives'          => $collectives,
                      'server_pub_key_path'  => $server_pub_key_path,
                      'client_pub_key_path'  => $client_pub_key_path,
                      'client_priv_key_path' => $client_priv_key_path,
                      'connector'            => $connector,
                      'middleware_address'   => $middleware_address,
                      'middleware_port'      => $middleware_port,
                      'mcollective_pwd'      => $mcollective_pwd,
                      'puppet_ssl_dir'       => $puppet_ssl_dir,
                    }
                  ),
  }

}



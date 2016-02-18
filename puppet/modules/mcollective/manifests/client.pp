class mcollective::client (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::mcollective::params']) { include '::mcollective::params' }
  $collectives        = $::mcollective::params::client_collectives
  $client_private_key = $::mcollective::params::client_private_key
  $client_public_key  = $::mcollective::params::client_public_key
  $server_public_key  = $::mcollective::params::server_public_key
  $connector          = $::mcollective::params::connector
  $middleware_address = $::mcollective::params::middleware_address
  $middleware_port    = $::mcollective::params::middleware_port
  $mcollective_pwd    = $::mcollective::params::mcollective_pwd
  $mco_tag            = $::mcollective::params::mco_tag
  $puppet_ssl_dir     = $::mcollective::params::puppet_ssl_dir

  if $client_public_key == 'NOT-DEFINED' {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the default value of the parameter
      `mcollective::params::client_public_key` is not valid.
      You must define it explicitly.
      |- END
  }

  if $client_private_key == 'NOT-DEFINED' {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the default value of the parameter
      `mcollective::params::client_private_key` is not valid.
      You must define it explicitly.
      |- END
  }

  if $server_public_key == 'NOT-DEFINED' {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the default value of the parameter
      `mcollective::params::server_public_key` is not valid.
      You must define it explicitly.
      |- END
  }

  require '::mcollective::package'
  require '::repository::mco'
  ensure_packages(['mcollective-flaf-clients'], { ensure => present, })

  # Just shortcuts.
  $client_keys_dir     = $::mcollective::package::client_keys_dir
  $allowed_clients_dir = $::mcollective::package::allowed_clients_dir

  # Paths of important files.
  $client_priv_key_path    = "${client_keys_dir}/${::fqdn}.priv-key.pem"
  $client_pub_key_path     = "${client_keys_dir}/${::fqdn}.pub-key.pem"
  $client_pub_key_path_exp = "${allowed_clients_dir}/${::fqdn}.pub-key.pem"
  $server_pub_key_path     = "${client_keys_dir}/servers-pub-key.pem"

  $collectives_final_value = $collectives.unique.sort

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
                      'collectives'          => $collectives_final_value,
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



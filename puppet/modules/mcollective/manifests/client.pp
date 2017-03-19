class mcollective::client {

  include '::mcollective::client::params'

  [
    $collectives,
    $private_key,
    $public_key,
    $server_public_key,
    $connector,
    $middleware_address,
    $middleware_port,
    $mcollective_pwd,
    $mco_tag,
    $mco_plugins,
    $puppet_ssl_dir,
    $collectives_sorted,
    $supported_distributions,
  ] = Class['::mcollective::client::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ::homemade::fail_if_undef($private_key,        'mcollective::server::params::private_key',        $title)
  ::homemade::fail_if_undef($public_key,         'mcollective::server::params::public_key',         $title)
  ::homemade::fail_if_undef($server_public_key,  'mcollective::server::params::server_public_key',  $title)
  ::homemade::fail_if_undef($middleware_address, 'mcollective::server::params::middleware_address', $title)
  ::homemade::fail_if_undef($middleware_port,    'mcollective::server::params::middleware_port',    $title)
  ::homemade::fail_if_undef($mcollective_pwd,    'mcollective::server::params::mcollective_pwd',    $title)
  ::homemade::fail_if_undef($puppet_ssl_dir,     'mcollective::server::params::puppet_ssl_dir',     $title)

  include '::mcollective::common_paths'
  [
    $client_priv_key_path,
    $client_pub_key_path,
    $client_pub_key_path_exp,
    $server_pub_key_path_for_client,
  ] = Class['::mcollective::common_paths']
  # For convenience.
  $server_pub_key_path = $server_pub_key_path_for_client

  ensure_packages($mco_plugins, { ensure => present, })

  include '::mcollective::client_keys_dir'

  file { $client_priv_key_path:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $private_key,
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
    content => $public_key,
  }

  # The same resource as above but with a different path.
  @@file { $client_pub_key_path_exp:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $public_key,
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
                      'collectives'          => $collectives_sorted,
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



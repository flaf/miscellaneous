class mcollective::client {

  $params = '::mcollective::client::params'
  include $params
  $collectives        = ::homemade::getvar("${params}::collectives", $title)
  $private_key        = ::homemade::getvar("${params}::private_key", $title)
  $public_key         = ::homemade::getvar("${params}::public_key", $title)
  $server_public_key  = ::homemade::getvar("${params}::server_public_key", $title)
  $connector          = ::homemade::getvar("${params}::connector", $title)
  $middleware_address = ::homemade::getvar("${params}::middleware_address", $title)
  $middleware_port    = ::homemade::getvar("${params}::middleware_port", $title)
  $mcollective_pwd    = ::homemade::getvar("${params}::mcollective_pwd", $title)
  $mco_tag            = ::homemade::getvar("${params}::mco_tag", $title)
  $mco_plugins        = ::homemade::getvar("${params}::mco_plugins", $title)
  $puppet_ssl_dir     = ::homemade::getvar("${params}::puppet_ssl_dir", $title)
  $collectives_sorted = ::homemade::getvar("${params}::collectives_sorted", $title)

  include '::mcollective::common_paths'
  $client_priv_key_path    = $::mcollective::common_paths::client_priv_key_path
  $client_pub_key_path     = $::mcollective::common_paths::client_pub_key_path
  $client_pub_key_path_exp = $::mcollective::common_paths::client_pub_key_path_exp
  $server_pub_key_path     = $::mcollective::common_paths::server_pub_key_path_for_client


  require '::mcollective::package'

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



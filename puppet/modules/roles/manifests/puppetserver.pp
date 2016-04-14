class roles::puppetserver {

  include '::roles::generic'

  include '::puppetserver'

  include '::mcollective::server::params'
  $server_public_key  = $::mcollective::server::params::public_key
  $middleware_address = $::mcollective::server::params::middleware_address
  $middleware_port    = $::mcollective::server::params::middleware_port
  $mcollective_pwd    = $::mcollective::server::params::mcollective_pwd
  $puppet_ssl_dir     = $::mcollective::server::params::puppet_ssl_dir

  # TODO: only if it's a mcollective client.
  class { 'mcollective::client::params':
    server_public_key  => $server_public_key,
    middleware_address => $middleware_address,
    middleware_port    => $middleware_port,
    mcollective_pwd    => $mcollective_pwd,
    puppet_ssl_dir     => $puppet_ssl_dir,
    # TODO collectives => all the datacenters...
  }

  include '::mcollective::client'

}



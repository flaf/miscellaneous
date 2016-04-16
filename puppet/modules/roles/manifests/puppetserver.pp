class roles::puppetserver {

  include '::roles::generic'
  include '::puppetserver'

  include '::roles::puppetserver::params'
  $is_mcollective_client = $::roles::puppetserver::params::is_mcollective_client

  # The mcollective client use the middleware of the mcollective server.
  include '::mcollective::server::params'
  $server_public_key  = $::mcollective::server::params::public_key
  $middleware_address = $::mcollective::server::params::middleware_address
  $middleware_port    = $::mcollective::server::params::middleware_port
  $mcollective_pwd    = $::mcollective::server::params::mcollective_pwd
  $puppet_ssl_dir     = $::mcollective::server::params::puppet_ssl_dir

  # TODO: only if it's a mcollective client.

  if $is_mcollective_client {

    include '::repository::puppet'
    include '::repository::mco'

    class { 'mcollective::client::params':
      server_public_key  => $server_public_key,
      middleware_address => $middleware_address,
      middleware_port    => $middleware_port,
      mcollective_pwd    => $mcollective_pwd,
      puppet_ssl_dir     => $puppet_ssl_dir,
      mco_plugin_clients => [ 'mcollective-flaf-clients' ],
      require            => [ Class['::repository::mco'],
                              Class['::repository::puppet'],
                            ],
      # TODO collectives => all the datacenters...
    }

    include '::mcollective::client'

  }

}



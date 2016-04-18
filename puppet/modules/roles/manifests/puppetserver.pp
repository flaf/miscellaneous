class roles::puppetserver {

  # Import parameters.
  include '::roles::puppetserver::params'

  # Include the role "generic" but the module puppetagent
  # must not manage the puppet.conf file.
  class { '::puppetagent::params': manage_puppetconf => false }
  include '::roles::generic'

  include '::puppetserver'

  if $::roles::puppetserver::params::is_mcollective_client {

    # The mcollective client use the middleware of the mcollective server.
    include '::mcollective::server::params'
    include '::repository::puppet'
    include '::repository::mco'

    class { 'mcollective::client::params':
      server_public_key  => $::mcollective::server::params::public_key,
      middleware_address => $::mcollective::server::params::middleware_address,
      middleware_port    => $::mcollective::server::params::middleware_port,
      mcollective_pwd    => $::mcollective::server::params::mcollective_pwd,
      puppet_ssl_dir     => $::mcollective::server::params::puppet_ssl_dir,
      mco_plugin_clients => [ 'mcollective-flaf-clients' ],
      require            => [ Class['::repository::mco'],
                              Class['::repository::puppet'],
                            ],
      # TODO collectives => all the datacenters...
    }

    include '::mcollective::client'

  }

}



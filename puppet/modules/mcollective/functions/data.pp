function mcollective::data {

  $default_collectives = $::datacenter ? {
    undef   => [ 'mcollective' ],
    default => [ 'mcollective', $::datacenter ],
  }

  if !defined(Class['::mcomiddleware::params']) { include '::mcomiddleware::params' }
  $middleware_port    = $::mcomiddleware::params::stomp_ssl_port
  $mcollective_pwd    = $::mcomiddleware::params::mcollective_pwd
  $client_collectives = $::mcomiddleware::params::exchanges.concat($default_collectives)

  if !defined(Class['::puppetagent::params']) { include '::puppetagent::params' }
  $puppet_ssl_dir = $::puppetagent::params::ssldir
  $puppet_bin_dir = $::puppetagent::params::bindir

  $supported_distribs = ['trusty', 'jessie'];

  {
    mcollective::params::client_collectives => $client_collectives,
    mcollective::params::client_private_key => undef,
    mcollective::params::client_public_key  => undef,
    mcollective::params::server_collectives => $default_collectives,
    mcollective::params::server_private_key => undef,
    mcollective::params::server_public_key  => undef,
    mcollective::params::server_enabled     => true,
    mcollective::params::connector          => 'rabbitmq',
    mcollective::params::middleware_address => undef,
    mcollective::params::middleware_port    => $middleware_port,
    mcollective::params::mcollective_pwd    => $mcollective_pwd,
    mcollective::params::mco_tag            => 'mcollective_client_public_key',
    mcollective::params::puppet_ssl_dir     => $puppet_ssl_dir,
    mcollective::params::puppet_bin_dir     => $puppet_bin_dir,

    mcollective::client::supported_distributions => $supported_distribs,

    mcollective::server::supported_distributions => $supported_distribs,

    # Merging policy.
    lookup_options => {
                        mcollective::params::server_collectives => { merge => 'unique', },
                      },
  }

}



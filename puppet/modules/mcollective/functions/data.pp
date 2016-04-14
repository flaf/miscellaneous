function mcollective::data {

  $default_connector   = 'rabbitmq'
  $default_mco_tag     = 'mcollective_client_public_key'
  $default_collectives = $::datacenter ? {
    undef   => [ 'mcollective' ],
    default => [ 'mcollective', $::datacenter ],
  }

  $supported_distribs = ['trusty', 'jessie'];

  {
    mcollective::server::params::collectives        => $default_collectives,
    mcollective::server::params::private_key        => undef,
    mcollective::server::params::public_key         => undef,
    mcollective::server::params::service_enabled    => true,
    mcollective::server::params::connector          => $default_connector,
    mcollective::server::params::middleware_address => undef,
    mcollective::server::params::middleware_port    => undef,
    mcollective::server::params::mcollective_pwd    => undef,
    mcollective::server::params::mco_tag            => $default_mco_tag,
    mcollective::server::params::puppet_ssl_dir     => undef,
    mcollective::server::params::puppet_bin_dir     => undef,

    mcollective::client::params::collectives        => $default_collectives,
    mcollective::client::params::private_key        => undef,
    mcollective::client::params::public_key         => undef,
    mcollective::client::params::server_public_key  => undef,
    mcollective::client::params::connector          => $default_connector,
    mcollective::client::params::middleware_address => undef,
    mcollective::client::params::middleware_port    => undef,
    mcollective::client::params::mcollective_pwd    => undef,
    mcollective::client::params::mco_tag            => $default_mco_tag,
    mcollective::client::params::puppet_ssl_dir     => undef,

    mcollective::client::supported_distributions => $supported_distribs,
    mcollective::server::supported_distributions => $supported_distribs,

    # Merging policy.
    lookup_options => {
                        mcollective::params::server_collectives => { merge => 'unique', },
                      },
  }

}



function mcollective::data {

  if !defined(Class['::mcomiddleware::params']) { include '::mcomiddleware::params' }
  $middleware_address = $::mcomiddleware::params::stomp_ssl_ip
  $middleware_port    = $::mcomiddleware::params::stomp_ssl_port
  $mcollective_pwd    = $::mcomiddleware::params::mcollective_pwd

  if !defined(Class['::puppetagent::params']) { include '::puppetagent::params' }
  $puppet_ssl_dir = $::puppetagent::params::ssldir

  $collectives = $::datacenter ? {
    undef   => [ 'mcollective' ],
    default => [ 'mcollective', $::datacenter ],
  }

  $supported_distribs = ['trusty', 'jessie'];

  {
    mcollective::params::collectives        => $collectives,
    mcollective::params::client_private_key => 'NOT-DEFINED',
    mcollective::params::client_public_key  => 'NOT-DEFINED',
    mcollective::params::server_private_key => 'NOT-DEFINED',
    mcollective::params::server_public_key  => 'NOT-DEFINED',
    mcollective::params::server_enabled     => true,
    mcollective::params::connector          => 'rabbitmq',
    mcollective::params::middleware_address => $middleware_address,
    mcollective::params::middleware_port    => $middleware_port,
    mcollective::params::mcollective_pwd    => $mcollective_pwd,
    mcollective::params::mco_tag            => 'mcollective_client_public_key',
    mcollective::params::puppet_ssl_dir     => $puppet_ssl_dir,

    mcollective::client::supported_distributions => $supported_distribs,

    mcollective::server::supported_distributions => $supported_distribs,
  }

}



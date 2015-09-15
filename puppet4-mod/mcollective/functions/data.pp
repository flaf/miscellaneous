function mcollective::data {

  $conf = lookup('mcollective', Hash[String[1], Data, 1], 'hash')

  if ! $conf.has_key('middleware_admin_pwd') {
    fail("The `mcollective` entry must have a `middleware_admin_pwd` key.")
  }

  if ! $conf.has_key('mcollective_pwd') {
    fail("The `mcollective` entry must have a `mcollective_pwd` key.")
  }

  if ! $conf.has_key('middleware_address') {
    fail("The `mcollective` entry must have a `middleware_address` key.")
  }

  if ! $conf.has_key('server_private_key') {
    fail("The `mcollective` entry must have a `server_private_key` key.")
  }

  if ! $conf.has_key('server_public_key') {
    fail("The `mcollective` entry must have a `server_public_key` key.")
  }

  if ! $conf.has_key('client_private_key') {
    fail("The `mcollective` entry must have a `client_private_key` key.")
  }

  if ! $conf.has_key('client_public_key') {
    fail("The `mcollective` entry must have a `client_public_key` key.")
  }

  if ! $conf.has_key('tag') {
    fail("The `mcollective` entry must have a `tag` key.")
  }

  $puppet_ssl_dir      = '/etc/puppetlabs/puppet/ssl'
  $mco_server_keys_dir = '/etc/puppetlabs/mcollective/server-keys'
  $mco_client_keys_dir = '/etc/puppetlabs/mcollective/client-keys'
  $connector           = 'rabbitmq'
  $middleware_port     = 61614
  $supported_distribs  = ['trusty', 'jessie'];

  { mcollective::middleware::stomp_ssl_ip            => '0.0.0.0',
    mcollective::middleware::stomp_ssl_port          => 61614,
    mcollective::middleware::puppet_ssl_dir          => $puppet_ssl_dir,
    mcollective::middleware::admin_pwd               => $conf['middleware_admin_pwd'],
    mcollective::middleware::mcollective_pwd         => $conf['mcollective_pwd'],
    mcollective::middleware::supported_distributions => [ 'trusty' ], # Currently only
                                                                      # Trusty for the middleware

    mcollective::server::server_private_key          => $conf['server_private_key'],
    mcollective::server::server_public_key           => $conf['server_public_key'],
    mcollective::server::mco_tag                     => $conf['tag'],
    mcollective::server::connector                   => $connector,
    mcollective::server::middleware_server           => $conf['middleware_address'],
    mcollective::server::middleware_port             => $middleware_port,
    mcollective::server::mcollective_pwd             => $conf['mcollective_pwd'],
    mcollective::server::puppet_ssl_dir              => $puppet_ssl_dir,
    mcollective::server::mco_server_keys_dir         => $mco_server_keys_dir,
    mcollective::server::mco_client_keys_dir         => $mco_client_keys_dir,
    mcollective::server::supported_distributions     => $supported_distribs,


    mcollective::client::client_private_key          => $conf['client_private_key'],
    mcollective::client::client_public_key           => $conf['client_public_key'],
    mcollective::client::mco_tag                     => $conf['tag'],
    mcollective::client::connector                   => $connector,
    mcollective::client::middleware_server           => $conf['middleware_address'],
    mcollective::client::middleware_port             => $middleware_port,
    mcollective::client::mcollective_pwd             => $conf['mcollective_pwd'],
    mcollective::client::puppet_ssl_dir              => $puppet_ssl_dir,
    mcollective::client::mco_client_keys_dir         => $mco_client_keys_dir,
    mcollective::client::supported_distributions     => $supported_distribs,
  }

}



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

  $middleware_port = 61614;

  { mcollective::middleware::stomp_ssl_ip            => '0.0.0.0',
    mcollective::middleware::stomp_ssl_port          => 61614,
    mcollective::middleware::puppet_ssl_dir          => '/etc/puppetlabs/puppet/ssl',
    mcollective::middleware::admin_pwd               => $conf['middleware_admin_pwd'],
    mcollective::middleware::mcollective_pwd         => $conf['mcollective_pwd'],
    mcollective::middleware::supported_distributions => [ 'trusty' ],

    mcollective::server::server_private_key          => $conf['server_private_key'],
    mcollective::server::server_public_key           => $conf['server_public_key'],
    mcollective::server::connector                   => 'rabbitmq',
    mcollective::server::middleware_server           => $conf['middleware_address'],
    mcollective::server::middleware_port             => $middleware_port,
    mcollective::server::mcollective_pwd             => $conf['mcollective_pwd'],
    mcollective::server::puppet_ssl_dir              => '/etc/puppetlabs/puppet/ssl',
    mcollective::server::supported_distributions     => ['trusty', 'jessie'],
  }

}



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
    # Call fail() is a bad idea. If the host is just a
    # mcollective server and not a client, the key will not
    # exist (because defined only in the $client.yaml file).
    #fail("The `mcollective` entry must have a `client_private_key` key.")

    # In this case, the parameter will be undef and if the
    # host is a mcollective client, the absence of this
    # parameter in mcollective::client will raise an error.
    $client_private_key = undef
  } else {
    $client_private_key = $conf['client_private_key']
  }

  if ! $conf.has_key('client_public_key') {
    # Call fail() is a bad idea. If the host is just a
    # mcollective server and not a client, the key will not
    # exist (because defined only in the $client.yaml file).
    #fail("The `mcollective` entry must have a `client_public_key` key.")

    # In this case, the parameter will be undef and if the
    # host is a mcollective client, the absence of this
    # parameter in mcollective::client will raise an error.
    $client_public_key = undef
  } else {
    $client_public_key = $conf['client_public_key']
  }

  if ! $conf.has_key('tag') {
    # Call fail() is a bad idea. If the host is just a
    # middleware and not a mco client neither a mco server,
    # the key will not exist.
    $mco_tag = undef
  } else {
    $mco_tag = $conf['tag']
  }

  $puppet_ssl_dir     = '/etc/puppetlabs/puppet/ssl'
  $connector          = 'rabbitmq'
  $middleware_port    = 61614
  $supported_distribs = ['trusty', 'jessie'];

  { mcollective::middleware::stomp_ssl_ip            => '0.0.0.0',
    mcollective::middleware::stomp_ssl_port          => 61614,
    mcollective::middleware::puppet_ssl_dir          => $puppet_ssl_dir,
    mcollective::middleware::admin_pwd               => $conf['middleware_admin_pwd'],
    mcollective::middleware::mcollective_pwd         => $conf['mcollective_pwd'],
    # Currently, the mcollective::middleware works only Ubuntu Trusty.
    mcollective::middleware::supported_distributions => [ 'trusty' ],


    mcollective::server::server_private_key      => $conf['server_private_key'],
    mcollective::server::server_public_key       => $conf['server_public_key'],
    mcollective::server::connector               => $connector,
    mcollective::server::middleware_server       => $conf['middleware_address'],
    mcollective::server::middleware_port         => $middleware_port,
    mcollective::server::mcollective_pwd         => $conf['mcollective_pwd'],
    mcollective::server::mco_tag                 => $mco_tag,
    mcollective::server::puppet_ssl_dir          => $puppet_ssl_dir,
    mcollective::server::supported_distributions => $supported_distribs,


    mcollective::client::client_private_key      => $conf['client_private_key'],
    mcollective::client::client_public_key       => $conf['client_public_key'],
    mcollective::client::server_public_key       => $conf['server_public_key'],
    mcollective::client::mco_tag                 => $mco_tag,
    mcollective::client::connector               => $connector,
    mcollective::client::middleware_server       => $conf['middleware_address'],
    mcollective::client::middleware_port         => $middleware_port,
    mcollective::client::mcollective_pwd         => $conf['mcollective_pwd'],
    mcollective::client::puppet_ssl_dir          => $puppet_ssl_dir,
    mcollective::client::supported_distributions => $supported_distribs,
  }

}



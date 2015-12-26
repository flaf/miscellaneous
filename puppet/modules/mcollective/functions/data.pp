function mcollective::data {

  $conf = lookup('mcollective', Hash[String[1], Data, 1], 'hash')

  # The key is necessary for all classes of this module.
  if ! $conf.has_key('middleware_mcollective_pwd') {
    fail("The `mcollective` entry must have a `middleware_mcollective_pwd` key.")
  }

  # For the remaining keys, sometimes they are necessary,
  # sometimes not. It depends on the called class. So we
  # don't use fail() if a such key is not present because if
  # the key is unnecessary the fail() function has no sense.
  # So, if a such key are not present, we define it to
  # undef. In this way, if a key is necessary but not
  # present in hiera, there will be an error because the
  # class will not receive a mandatory parameter (receive a
  # parameter defined to undef is equivalent to receive no
  # parameter).

  if $conf.has_key('server_private_key') {
    $server_private_key = $conf['server_private_key']
  } else {
    $server_private_key = undef
  }

  if $conf.has_key('server_public_key') {
    $server_public_key = $conf['server_public_key']
  } else {
    $server_public_key = undef
  }

  if $conf.has_key('server_enabled') {
    $server_enabled = $conf['server_enabled']
  } else {
    $server_enabled = true
  }

  if $conf.has_key('middleware_address') {
    $middleware_address = $conf['middleware_address']
  } else {
    $middleware_address = undef
  }

  if $conf.has_key('tag') {
    $mco_tag = $conf['tag']
  } else {
    $mco_tag = 'mcollective_client_public_key'
  }

  if $conf.has_key('client_private_key') {
    $client_private_key = $conf['client_private_key']
  } else {
    $client_private_key = undef
  }

  if $conf.has_key('client_public_key') {
    $client_public_key = $conf['client_public_key']
  } else {
    $client_public_key = undef
  }

  if $conf.has_key('mcollectives') {
    $mcollectives = $conf['mcollectives']
  } else {
    $mcollectives = [ 'mcollective' ]
  }

  $puppet_ssl_dir     = '/etc/puppetlabs/puppet/ssl'
  $connector          = 'rabbitmq'
  $middleware_port    = 61614
  $ssl_versions       = ['tlsv1.2', 'tlsv1.1']
  $supported_distribs = ['trusty', 'jessie'];

  {
    mcollective::middleware::stomp_ssl_ip            => '0.0.0.0',
    mcollective::middleware::stomp_ssl_port          => $middleware_port,
    mcollective::middleware::ssl_versions            => $ssl_versions,
    mcollective::middleware::puppet_ssl_dir          => $puppet_ssl_dir,
    mcollective::middleware::admin_pwd               => sha1($::fqdn),
    mcollective::middleware::mcollective_pwd         => $conf['middleware_mcollective_pwd'],
    mcollective::middleware::supported_distributions => $supported_distribs,


    mcollective::server::collectives             => $mcollectives,
    mcollective::server::server_private_key      => $server_private_key,
    mcollective::server::server_public_key       => $server_public_key,
    mcollective::server::server_enabled          => $server_enabled,
    mcollective::server::connector               => $connector,
    mcollective::server::middleware_address      => $middleware_address,
    mcollective::server::middleware_port         => $middleware_port,
    mcollective::server::mcollective_pwd         => $conf['middleware_mcollective_pwd'],
    mcollective::server::mco_tag                 => $mco_tag,
    mcollective::server::puppet_ssl_dir          => $puppet_ssl_dir,
    mcollective::server::supported_distributions => $supported_distribs,


    mcollective::client::client_private_key      => $conf['client_private_key'],
    mcollective::client::client_public_key       => $conf['client_public_key'],
    mcollective::client::server_public_key       => $conf['server_public_key'],
    mcollective::client::mco_tag                 => $mco_tag,
    mcollective::client::connector               => $connector,
    mcollective::client::middleware_address      => $middleware_address,
    mcollective::client::middleware_port         => $middleware_port,
    mcollective::client::mcollective_pwd         => $conf['middleware_mcollective_pwd'],
    mcollective::client::puppet_ssl_dir          => $puppet_ssl_dir,
    mcollective::client::supported_distributions => $supported_distribs,
  }

}



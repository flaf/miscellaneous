function mcollective::data {

  $conf = lookup('mcollective', Hash[String[1], Data, 1], 'hash')

  if ! $conf.has_key('middleware_admin_pwd') {
    fail("The `mcollective` entry must have a `middleware_admin_pwd` key.")
  }
  if ! $conf.has_key('mcollective_pwd') {
    fail("The `mcollective` entry must have a `mcollective_pwd` key.")
  };

  { mcollective::middleware::stomp_ssl_ip            => '0.0.0.0',
    mcollective::middleware::stomp_ssl_port          => 61614,
    mcollective::middleware::puppet_ssl_dir          => '/etc/puppetlabs/puppet/ssl',
    mcollective::middleware::admin_pwd               => $conf['middleware_admin_pwd'],
    mcollective::middleware::mcollective_pwd         => $conf['mcollective_pwd'],
    mcollective::middleware::supported_distributions => [ 'trusty' ],
  }

}



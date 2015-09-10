function mcollective::data {

  { mcollective::middleware::stomp_ssl_ip            => '0.0.0.0',
    mcollective::middleware::stomp_ssl_port          => 61614,
    mcollective::middleware::puppet_ssl_dir          => '/etc/puppetlabs/puppet/ssl',
    mcollective::middleware::admin_pwd               => md5("${::fqdn}-admin"),
    mcollective::middleware::mcollective_pwd         => md5("${::fqdn}-mcollective"),
    mcollective::middleware::supported_distributions => [ 'trusty' ],
  }

}



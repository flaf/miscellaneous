function puppetagent::data {

  # Warning: the $server_facts will be defined for the node
  #          only if the parameter `trusted_server_facts`
  #          is set to true in the puppet.conf of the server.
  if $::server_facts {
    $server = $::server_facts['servername']
  } else {
    $server = 'puppet'
  };

  {
    puppetagent::service_enabled         => false,
    puppetagent::runinterval             => '7d',
    puppetagent::server                  => $server,
    puppetagent::ca_server               => '$server',
    puppetagent::cron                    => 'per-week',
    puppetagent::manage_puppetconf       => true,
    puppetagent::supported_distributions => [ 'trusty', 'jessie' ],
  }

}


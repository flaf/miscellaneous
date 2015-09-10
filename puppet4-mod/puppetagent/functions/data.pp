function puppetagent::data {

  # Warning: the $server_facts will be defined for the node
  #          only if the parameter `trusted_server_facts`
  #          is set to true in the puppet.conf of the server.
  if $server_facts {
    $server = $server_facts['servername']
  } else {
    $server = 'puppet'
  }

  # Collection and version of the package puppet-agent
  # must be found in hiera or in the environment.
  $conf = lookup('puppetagent', Hash[String[1], String[1], 1], 'hash')

  if ! $conf.has_key('collection') {
    fail("The `puppetagent` entry must have a `collection` key.")
  }
  if ! $conf.has_key('package_version') {
    fail("The `puppetagent` entry must have a `package_version` key.")
  };

  { puppetagent::service_enabled         => false,
    puppetagent::runinterval             => '7d',
    puppetagent::server                  => $server,
    puppetagent::collection              => $conf['collection'],
    puppetagent::package_version         => $conf['package_version'],
    puppetagent::stage_package           => 'repository',
    puppetagent::src                     => false,
    puppetagent::module_off              => false,
    puppetagent::supported_distributions => [ 'trusty', 'jessie' ],
  }

}



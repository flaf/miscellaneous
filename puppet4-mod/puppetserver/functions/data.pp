function puppetserver::data {

  # '2g' => 2GB, '512m' => 512MB etc.
  $puppet_memory           = '1g'
  $puppetdb_memory         = '1g'
  $retrieve_common_hiera   = true
  $puppetdb_fqdn           = $::server_facts['servername']
  $ca_server               = $::server_facts['servername']
  $puppet_server_for_agent = $::server_facts['servername']
  $module_repository       = ''
  $puppetdb_name           = 'puppet'
  $puppetdb_user           = 'puppet'
  $puppetdb_pwd            = md5($::fqdn)
  $supported_distributions = ['trusty'];

  { puppetserver::puppet_memory           => $puppet_memory,
    puppetserver::puppetdb_memory         => $puppetdb_memory,
    puppetserver::retrieve_common_hiera   => $retrieve_common_hiera,
    puppetserver::puppetdb_fqdn           => $puppetdb_fqdn,
    puppetserver::ca_server               => $ca_server,
    puppetserver::puppet_server_for_agent => $puppet_server_for_agent,
    puppetserver::module_repository       => $module_repository,
    puppetserver::puppetdb_name           => $puppetdb_name,
    puppetserver::puppetdb_user           => $puppetdb_user,
    puppetserver::puppetdb_pwd            => $puppetdb_pwd,
    puppetserver::supported_distributions => $supported_distributions,
  }

}



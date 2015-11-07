function puppetserver::data {

  # '2g' => 2GB, '512m' => 512MB etc.
  $puppet_memory           = '1g'
  $puppetdb_memory         = '1g'
  $profile                 = 'client'
  $modules_repository      = ''
  $puppetdb_name           = 'puppet'
  $puppetdb_user           = 'puppet'
  $puppetdb_pwd            = sha1($::fqdn)
  $modules_versions        = {} # no pinning by default
  $max_groups              = 3
  $groups_from_master      = []
  $supported_distributions = [ 'trusty' ];

  {
    puppetserver::puppet_memory           => $puppet_memory,
    puppetserver::puppetdb_memory         => $puppetdb_memory,
    puppetserver::profile                 => $profile,
    puppetserver::modules_repository      => $modules_repository,
    puppetserver::puppetdb_name           => $puppetdb_name,
    puppetserver::puppetdb_user           => $puppetdb_user,
    puppetserver::puppetdb_pwd            => $puppetdb_pwd,
    puppetserver::modules_versions        => $modules_versions,
    puppetserver::max_groups              => $max_groups,
    puppetserver::groups_from_master      => $groups_from_master,
    puppetserver::supported_distributions => $supported_distributions,
  }

}



function puppetserver::data {

  # '2g' => 2GB, '512m' => 512MB etc.
  $puppet_memory           = '1g'
  $puppetdb_memory         = '1g'
  $profile                 = undef
  $modules_repository      = undef
  $puppetdb_name           = 'puppet'
  $puppetdb_user           = 'puppet'
  $puppetdb_pwd            = undef
  $modules_versions        = {} # no pinning by default
  $max_groups              = 5
  $groups_from_master      = []
  $supported_distributions = [ 'trusty' ];

  {
    puppetserver::params::puppet_memory      => $puppet_memory,
    puppetserver::params::puppetdb_memory    => $puppetdb_memory,
    puppetserver::params::profile            => $profile,
    puppetserver::params::modules_repository => $modules_repository,
    puppetserver::params::puppetdb_name      => $puppetdb_name,
    puppetserver::params::puppetdb_user      => $puppetdb_user,
    puppetserver::params::puppetdb_pwd       => $puppetdb_pwd,
    puppetserver::params::modules_versions   => $modules_versions,
    puppetserver::params::max_groups         => $max_groups,
    puppetserver::params::groups_from_master => $groups_from_master,

    puppetserver::supported_distributions => $supported_distributions,
  }

}



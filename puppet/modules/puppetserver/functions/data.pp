function puppetserver::data {

  # '2g' => 2GB, '512m' => 512MB etc.
  $puppet_memory           = '1g'
  $puppetdb_memory         = '1g'
  $profile                 = undef
  $modules_repository      = undef
  $strict                  = undef
  $puppetdb_name           = 'puppet'
  $puppetdb_user           = 'puppet'
  $puppetdb_pwd            = undef
  $puppetdb_certwhitelist  = [ $::fqdn ]
  $modules_versions        = {} # no pinning by default
  $max_groups              = 10
  $datacenters             = undef
  $groups_from_master      = []
  $mcrypt_pwd              = undef
  $authorized_backup_keys  = {}
  $supported_distributions = [ 'trusty' ]
  $sd                      = 'supported_distributions';

  {
    puppetserver::params::puppet_memory          => $puppet_memory,
    puppetserver::params::puppetdb_memory        => $puppetdb_memory,
    puppetserver::params::profile                => $profile,
    puppetserver::params::modules_repository     => $modules_repository,
    puppetserver::params::strict                 => $strict,
    puppetserver::params::puppetdb_name          => $puppetdb_name,
    puppetserver::params::puppetdb_user          => $puppetdb_user,
    puppetserver::params::puppetdb_pwd           => $puppetdb_pwd,
    puppetserver::params::puppetdb_certwhitelist => $puppetdb_certwhitelist,
    puppetserver::params::modules_versions       => $modules_versions,
    puppetserver::params::max_groups             => $max_groups,
    puppetserver::params::datacenters            => $datacenters,
    puppetserver::params::groups_from_master     => $groups_from_master,
    puppetserver::params::mcrypt_pwd             => $mcrypt_pwd,
    puppetserver::params::authorized_backup_keys => $authorized_backup_keys,
   "puppetserver::params::${sd}"                 => $supported_distributions,
  }

}



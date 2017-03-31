function puppetserver::data {

  # '2g' => 2GB, '512m' => 512MB etc.
  $puppet_memory           = '2g'
  $puppetdb_memory         = '512m'
  $profile                 = undef
  $modules_repository      = undef
  $http_proxy              = undef
  $strict                  = undef
  $strict_variables        = true
  $environments            = [ 'production' ]
  $puppetdb_name           = 'puppet'
  $puppetdb_user           = 'puppet'
  $puppetdb_pwd            = undef
  $puppetdb_certwhitelist  = [ $::fqdn ]
  $max_groups              = 10
  $datacenters             = undef
  $mcrypt_pwd              = undef
  $authorized_backup_keys  = {}
  $supported_distributions = [ 'trusty' ]
  $sd                      = 'supported_distributions';

  {
    puppetserver::params::puppet_memory          => $puppet_memory,
    puppetserver::params::puppetdb_memory        => $puppetdb_memory,
    puppetserver::params::profile                => $profile,
    puppetserver::params::modules_repository     => $modules_repository,
    puppetserver::params::http_proxy             => $http_proxy,
    puppetserver::params::strict                 => $strict,
    puppetserver::params::strict_variables       => $strict_variables,
    puppetserver::params::environments           => $environments,
    puppetserver::params::puppetdb_name          => $puppetdb_name,
    puppetserver::params::puppetdb_user          => $puppetdb_user,
    puppetserver::params::puppetdb_pwd           => $puppetdb_pwd,
    puppetserver::params::puppetdb_certwhitelist => $puppetdb_certwhitelist,
    puppetserver::params::max_groups             => $max_groups,
    puppetserver::params::datacenters            => $datacenters,
    puppetserver::params::mcrypt_pwd             => $mcrypt_pwd,
    puppetserver::params::authorized_backup_keys => $authorized_backup_keys,
   "puppetserver::params::${sd}"                 => $supported_distributions,
  }

}



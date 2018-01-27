class puppetserver::params (
  String[1]                               $puppet_memory,
  String[1]                               $puppetdb_memory,
  Optional[ Puppetserver::Profile ]       $profile = undef,
  Optional[ String[1] ]                   $modules_repository,
  Optional[ Puppetserver::HttpProxy ]     $http_proxy,
  Optional[ Puppetserver::Strict ]        $strict,
  Optional[ Boolean ]                     $strict_variables,
  Array[String[1], 1]                     $environments,
  String[1]                               $puppetdb_name,
  String[1]                               $puppetdb_user,
  Optional[ String[1] ]                   $puppetdb_pwd,
  Array[String[1]]                        $puppetdb_certwhitelist,
  Integer[1]                              $max_groups,
  Optional[ Array[String[1], 1] ]         $datacenters,
  Optional[ String[1] ]                   $mcrypt_pwd,
  Hash[ String[1], Puppetserver::Pubkey ] $authorized_backup_keys,
  Integer[1]                              $backend_etc_retention,
  Array[String[1], 1]                     $supported_distributions,
) {

  # Variables present in several classes of this modules.
  # Maybe should be retrieve from the puppetagent module...?
  $puppetlabs_path   = '/etc/puppetlabs'
  $puppet_path       = "${puppetlabs_path}/puppet"
  $puppet_conf       = "${puppet_path}/puppet.conf"
  $ssldir            = "${puppet_path}/ssl"
  $puppet_bin_dir    = '/opt/puppetlabs/puppet/bin'

}



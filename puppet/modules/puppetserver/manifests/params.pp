class puppetserver::params (
  String[1]                                $puppet_memory,
  String[1]                                $puppetdb_memory,
  Optional[ Enum['autonomous', 'client'] ] $profile = undef,
  Optional[ String[1] ]                    $modules_repository,
  Optional[ Boolean ]                      $strict_variables,
  String[1]                                $puppetdb_name,
  String[1]                                $puppetdb_user,
  Optional[ String[1] ]                    $puppetdb_pwd,
  Hash[String[1], String[1]]               $modules_versions,
  Integer[1]                               $max_groups,
  Array[String[1]]                         $groups_from_master,
  Optional[ String[1] ]                    $mcrypt_pwd,
  Hash[ String[1], Puppetserver::Pubkey ]  $authorized_backup_keys,
  Array[String[1], 1]                      $supported_distributions,
) {

  # Variables present in several classes of this modules.
  # Maybe should be retrieve from the puppetagent module...?
  $puppetlabs_path   = '/etc/puppetlabs'
  $puppet_path       = "${puppetlabs_path}/puppet"
  $ssldir            = "${puppet_path}/ssl"
  $puppet_bin_dir    = '/opt/puppetlabs/puppet/bin'

  ::homemade::is_supported_distrib($supported_distributions, $title)

}



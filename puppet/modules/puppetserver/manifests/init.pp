class puppetserver (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::puppetserver::params']) { include '::puppetserver::params' }
  $puppet_memory         = $::puppetserver::params::puppet_memory
  $puppetdb_memory       = $::puppetserver::params::puppetdb_memory
  $profile               = $::puppetserver::params::profile
  $modules_repository    = $::puppetserver::params::modules_repository
  $strict_variables      = $::puppetserver::params::strict_variables
  $puppetdb_name         = $::puppetserver::params::puppetdb_name
  $puppetdb_user         = $::puppetserver::params::puppetdb_user
  $puppetdb_pwd          = $::puppetserver::params::puppetdb_pwd
  $modules_versions      = $::puppetserver::params::modules_versions
  $max_groups            = $::puppetserver::params::max_groups
  $groups_from_master    = $::puppetserver::params::groups_from_master
  $mcrypt_pwd            = $::puppetserver::params::mcrypt_pwd
  $authorized_backup_key = $::puppetserver::params::authorized_backup_key

  # The "profile" parameter is mandatory.
  ::homemade::fail_if_undef($profile, 'puppetserver::params::profile', $title)

  # The "puppetdb_pwd" parameter is mandatory only if the
  # profile is "autonomous".
  if $profile == 'autonomous' {
    ::homemade::fail_if_undef($puppetdb_pwd, 'puppetserver::params::puppetdb_pwd', $title)
  }

  # The mcrypt password is mandatory.
  ::homemade::fail_if_undef($mcrypt_pwd, 'puppetserver::params::mcrypt_pwd', $title)

  # From params but there are not parameters of the class,
  # just common internal values.
  $puppetlabs_path   = $::puppetserver::params::puppetlabs_path
  $puppet_path       = $::puppetserver::params::puppet_path
  $ssldir            = $::puppetserver::params::ssldir
  $puppet_bin_dir    = $::puppetserver::params::puppet_bin_dir

  include '::puppetserver::puppetconf'
  include '::puppetserver::backup'

  if $profile == 'autonomous' {

    class { '::puppetserver::postgresql':
      require => Class['::puppetserver::puppetconf'],
    }

    class { '::puppetserver::puppetdb':
      require => Class['::puppetserver::postgresql'],
    }

  }

}



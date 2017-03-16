class puppetserver {

  include '::puppetserver::params'

  [
    $puppet_memory,
    $puppetdb_memory,
    $profile,
    $modules_repository,
    $http_proxy,
    $proxy_for_modrepo,
    $strict,
    $puppetdb_name,
    $puppetdb_user,
    $puppetdb_pwd,
    $puppetdb_certwhitelist,
    $modules_versions,
    $max_groups,
    $datacenters,
    $groups_from_master,
    $mcrypt_pwd,
    $authorized_backup_keys,
    $supported_distributions,
  ] = Class['::puppetserver::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # The "profile" parameter is mandatory.
  ::homemade::fail_if_undef($profile, 'puppetserver::params::profile', $title)

  # The "puppetdb_pwd" parameter is mandatory only if the
  # profile is "autonomous".
  if $profile == 'autonomous' {
    ::homemade::fail_if_undef($puppetdb_pwd, 'puppetserver::params::puppetdb_pwd', $title)
  }

  if $profile == 'client' {
    ::homemade::fail_if_undef($datacenters, 'puppetserver::params::datacenters', $title, @("END"/L))
      On a puppetserver with the `client` profile, you must \
      provide a value for the `datacenters` parameter.
      |- END
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



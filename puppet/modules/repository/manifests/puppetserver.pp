class repository::puppetserver {

  include '::repository::puppetserver::params'

  [
    $pinning_puppetserver_version,
    $pinning_puppetdb_version,
    $pinning_puppetdb_termini_version,
    $supported_distributions,
  ] = Class['::repository::puppetserver::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ::homemade::fail_if_undef($pinning_puppetserver_version, 'pinning_puppetserver_version', $title)
  ::homemade::fail_if_undef($pinning_puppetdb_version, 'pinning_puppetdb_version', $title)
  ::homemade::fail_if_undef($pinning_puppetdb_termini_version, 'pinning_puppetdb_termini_version', $title)

  if $pinning_puppetserver_version != 'none' {
    # About pinning => `man apt_preferences`.
    repository::pinning { 'puppetserver':
      explanation => 'To ensure the version of the puppetserver package.',
      packages    => 'puppetserver',
      version     => $pinning_puppetserver_version,
      priority    => 990,
    }
  }

  if $pinning_puppetdb_version != 'none' {
    # About pinning => `man apt_preferences`.
    repository::pinning { 'puppetdb':
      explanation => 'To ensure the version of the puppetdb package.',
      packages    => 'puppetdb',
      version     => $pinning_puppetdb_version,
      priority    => 990,
    }
  }

  if $pinning_puppetdb_termini_version != 'none' {
    # About pinning => `man apt_preferences`.
    repository::pinning { 'puppetdb-termini':
      explanation => 'To ensure the version of the puppetdb-termini package.',
      packages    => 'puppetdb-termini',
      version     => $pinning_puppetdb_termini_version,
      priority    => 990,
    }
  }

}



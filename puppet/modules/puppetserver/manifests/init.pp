class puppetserver {

  include '::puppetserver::params'

  [
    $mcrypt_pwd,
    $datacenters,
    $puppetdb_pwd,
    $profile,
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



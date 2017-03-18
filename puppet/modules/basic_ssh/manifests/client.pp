class basic_ssh::client {

  include '::basic_ssh::client::params'

  [
    $supported_distributions,
  ] = Class['::basic_ssh::client::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ensure_packages( [ 'openssh-client' ], { ensure => present } )

}



class basic_packages {

  include '::basic_packages::params'

  [ $supported_distributions ] = Class['::basic_packages::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $wanted_packages = [
    'man-db', # After a minimal Xenial installation, man is not present.
    'vim',
    'gawk',
    'bash-completion',
    'less',
    'lsb-release',
    'tree', # Warning, in Trusty, "tree" is in "universe".
    'tcpdump',
    'ethtool',
    'curl',
    'screen',
    'iperf',
    'atop',
  ]
  ensure_packages( $wanted_packages, { ensure => present } )

  $prohibited_packages = [
    'mlocate', # This package Provides the `locate` command
               # and is often installed by default on Ubuntu.
  ]
  ensure_packages( $prohibited_packages, { ensure => purged } )

}



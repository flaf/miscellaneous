class basic_packages (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $wanted_packages = [
    'vim',
    'gawk',
    'bash-completion',
    'less',
    'lsb-release',
    'tree', # Warning, in Trusty, "tree" is in "universe".
    'tcpdump',
    'curl',
    'screen',
  ]
  ensure_packages( $wanted_packages, { ensure => present } )

  $prohibited_packages = [
    'mlocate', # This package Provides the `locate` command
               # and is often installed by default on Ubuntu.
  ]
  ensure_packages( $prohibited_packages, { ensure => purged } )

}



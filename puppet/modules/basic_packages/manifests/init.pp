class basic_packages {

  include '::basic_packages::params'

  $wanted_packages = [
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



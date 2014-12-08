# Very basic Puppet class to ensure the installation of
# a ssh client.
#
# == Requirement/Dependencies
#
# Nothing.
#
# == Parameters
#
# No parameter.
#
# == Sample Usages
#
#  include '::ssh::client'
#
class ssh::client {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  if ! defined(Package['openssh-client']) {
    package { 'openssh-client':
      ensure => present,
    }
  }

}



# Very basic Puppet class to ensure the installation of
# a ssh client.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib.
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

  ensure_packages(['openssh-client', ], { ensure => present, })

}



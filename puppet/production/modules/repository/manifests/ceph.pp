# Puppet class to manage a ceph APT repository.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib and Puppetlabs-apt.
#
# == Parameters
#
# *version:*
# The version of Ceph to use.
# Currently, it can be only set to 'firefly' which is
# the default value.
#
# == Sample Usages
#
#  include '::repository::ceph'
#
# or:
#
#  class { '::repository::ceph':
#   version => 'firefly',
#  }
#
class repository::ceph (
  $version = 'firefly',
) {

  case $::lsbdistcodename {
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  validate_string($version)
  unless member(['firefly'], $version) {
    fail("Class ${title}, version `#{$version}` are not supported.")
  }

  apt::source { 'ceph':
    location    => "http://ceph.com/debian-${version}/",
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => '17ED316D',
    include_src => false,
  }

}



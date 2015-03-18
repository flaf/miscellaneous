# Puppet class to manage a specific APT repositories
# for radosgw.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib and Puppetlabs-apt.
#
# == Parameters
#
# No parameter.
#
# == Sample Usage
#
#  include '::repositories::radosgw'
#
class repositories::radosgw {

  case $::lsbdistcodename {
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  # Fingerprint of the APT key:
  #
  #   Ceph automated package build (Ceph automated package build)
  #   <sage@newdream.net>".
  #
  # To install this APT key:
  #
  #   url='https://raw.github.com/ceph/ceph/master/keys/autobuild.asc'
  #   wget -q -O- "$url" | apt-key add -
  #
  $key = 'FCC5CB2ED8E6F6FB79D5B3316EAEAE2203C3951A'

  apt::source { 'ceph-apache2':
    location    => "http://gitbuilder.ceph.com/apache2-deb-${::lsbdistcodename}-x86_64-basic/ref/master",
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => $key,
    include_src => false,
  }

  apt::source { 'ceph-fastcgi':
    location    => "http://gitbuilder.ceph.com/libapache-mod-fastcgi-deb-${::lsbdistcodename}-x86_64-basic/ref/master",
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => $key,
    include_src => false,
  }

}



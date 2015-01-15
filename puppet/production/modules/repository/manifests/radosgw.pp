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
# == Sample Usages
#
#  include '::repository::radosgw'
#
class repository::radosgw {

  case $::lsbdistcodename {
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  apt::source { 'ceph-apache2':
    location    => "http://gitbuilder.ceph.com/apache2-deb-${::lsbdistcodename}-x86_64-basic/ref/master",
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => '03C3951A',
    include_src => false,
  }

  apt::source { 'ceph-fastcgi':
    location    => "http://gitbuilder.ceph.com/libapache-mod-fastcgi-deb-${::lsbdistcodename}-x86_64-basic/ref/master",
    release     => $::lsbdistcodename,
    repos       => 'main',
    key         => '03C3951A',
    include_src => false,
  }

}



# Very basic Puppet class to ensure the installation of
# vim package. This class manages too a basic /root/.vimrc
# file.
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
#  include '::vim'
#
class vim {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  ensure_packages(['vim', ], { ensure => present, })

  file { '/root/.vimrc':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('vim/vimrc.erb'),
  }

}



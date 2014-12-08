# Very basic Puppet class to manage the /etc/puppet/puppet.conf file
# for a Puppet client.
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
#  include '::puppet::client'
#
class puppet::client {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  if ! defined(Package['puppet']) {
    package { 'puppet':
      ensure => present,
      before => File['/etc/puppet/puppet.conf'],
    }
  }

  file { '/etc/puppet/puppet.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet/puppet.conf.client.erb'),
  }

}



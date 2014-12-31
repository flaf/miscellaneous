# TODO: write documentation.
#       Impossible to use the metaparameter because
#       "@datacenter-foo" is invalid tag for puppet.
#       Depends on puppetlabs-stdlib and homemade_functions
#       modules.
#       Should be a private class, but when encapsulated
#       in a "profiles" class with a specific stage metaparameter,
#       you need to explicitly include this class in the
#       "profiles" class.
class hosts {

  #private("Sorry, ${title} is a private class.")

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  include '::hosts::refresh'

  file { '/etc/hosts.puppet.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    notify  => Class['::hosts::refresh'],
  }

  file {'/etc/hosts.puppet.d/README':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "Directory managed by Puppet, don't touch it.\n",
    require => File['/etc/hosts.puppet.d'],
  }

  file {'/etc/hosts':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    # Content will be set by an exec resource.
  }

  file { '/usr/local/sbin/refresh-hosts':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0754',
    source => 'puppet:///modules/hosts/refresh-hosts',
  }

}



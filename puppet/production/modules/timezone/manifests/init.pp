# Public class which allows to set the timezone of the system.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib.
#
# == Parameters
#
# *timezone*:
# The value of the timezone. Default value is 'Etc/UTC'.
#
# == Sample Usages
#
#  include '::timezone'
#
# or
#
#  class { '::timezone':
#    timezone => 'Europe/Paris',
#  }
#
class timezone (
  $timezone = 'Etc/UTC',
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  # Check parameters.
  unless is_string($timezone) and (! empty($timezone)) {
    fail("Problem in class ${title}, the `timezone` parameter must be a non empty string.")
  }

  file { '/etc/timezone':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "${timezone}\n",
  }

  exec { 'reconfigure-timezone':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'dpkg-reconfigure --frontend="noninteractive" tzdata',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    require     => File['/etc/timezone'],
    subscribe   => File['/etc/timezone'],
  }

}



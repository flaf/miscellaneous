# Class: timezone
#
# Public class which allow to set the timezone of the
# system.
#
# Parameters:
# - $timezone: the value of the timezone.
#   Default value is 'Etc/UTC'.
#
# Sample Usages:
#
#   include '::timezone'
#
# or
#
#   class { '::timezone':
#     timezone => 'Europe/Paris',
#   }
#
class timezone (
  $stage    = 'basis',
  $timezone = 'Etc/UTC',
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
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



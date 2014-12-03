# Class: locales
#
# Public class which allow to only set the default
# locale of the system.
# Depends on Puppetlabs-stdlib.
#
# Parameters:
# - $default_locale: the value of the default locale.
#   Default value is 'en_US.UTF-8'.
#
# Sample Usages:
#
#   include '::locales'
#
# or
#
#   class { '::locales':
#     default_locale => 'fr_FR.UTF-8',
#   }
#
class locales (
  $stage          = 'basis',
  $default_locale = 'en_US.UTF-8',
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  # Check parameters.
  unless is_string($default_locale) and (! empty($default_locale)) {
    fail("Problem in class ${title}, the `default_locale` parameter must be a non empty string.")
  }

  file { '/etc/default/locale':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "LANG=${default_locale}\n",
  }

  # In fact, this is the opposite. The command below
  # update the default locale and write in the
  # '/etc/default/locale' file. But, in this case,
  # the file is a good way to know if the default
  # locale is set as we want.
  exec { 'update-default-locale':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => "update-locale LANG='${default_locale}'",
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    require     => File['/etc/default/locale'],
    subscribe   => File['/etc/default/locale'],
  }

}



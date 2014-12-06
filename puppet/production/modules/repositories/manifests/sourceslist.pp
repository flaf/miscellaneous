# Public class which configures a minimalist and secure
# /etc/apt/sources.list file. For instance, with Ubuntu,
# the universe and multiverse repositories are not present
# because they are entirely unsupported by the Ubuntu team.
# If you need to these repositories, you should manage
# another resource in /etc/apt/sources.list.d/ with the
# apt puppet module.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib.
#
# == Parameters
#
# *url*:
# The url of an official repository. Default value depends on 
# the OS (Debian or Ubuntu), see the repositories::sourceslist::params
# puppet class.
#
# *add_src*:
# If you add source or not. Default value is false.
#
# == Sample Usages
#
#  include '::repositories::sourceslist'
#
# or, for a Ubuntu server in France:
#
#  class { '::repositories::sourceslist':
#    url     => 'http://fr.archive.ubuntu.com/ubuntu',
#    add_src => true,
#  }
#
class repositories::sourceslist (
  $stage   = repository,
  $url     = $::repositories::sourceslist::params::url,
  $add_src = false,
) inherits ::repositories::sourceslist::params {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  # Check parameters.
  unless is_string($url) and (! empty($url)) {
    fail("Problem in class ${title}, the `url` parameter must be a non empty string.")
  }
  unless is_bool($add_src) {
    fail("Problem in class ${title}, the `add_src` parameter must be a boolean.")
  }

  # Should be equal to "debian" or "ubuntu".
  $os_family = downcase($::lsbdistid)

  file { '/etc/apt/sources.list':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template("repositories/sourceslist/sources.list.${os_family}.erb"),
  }

  exec { 'sourceslist-apt-get-update':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'apt-get update',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    require     => File['/etc/apt/sources.list'],
    subscribe   => File['/etc/apt/sources.list'],
  }

}



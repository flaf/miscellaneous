# Very basic Puppet class to ensure the installation of
# a ssh server.
#
# == Requirement/Dependencies
#
# Nothing.
#
# == Parameters
#
# *permitrootlogin:*
# The value of the "PermitRootLogin" parameter.
# The default value is 'yes', ie root can open
# session via ssh with his UniX password. If set
# to 'no' root can't open session via ssh and
# if set to 'without-password' he can open session
# via ssh only with ssh private/public keys
#
# == Sample Usages
#
#  class { '::ssh::server':
#    permitrootlogin => 'without-password',
#  }
#
class ssh::server (
  $permitrootlogin = 'yes',
){

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  validate_string($permitrootlogin)

  if ! defined(Package['openssh-server']) {
    package { 'openssh-server':
      ensure => present,
    }
  }

  file_line { 'edit-PermitRootLogin-param':
    path    => '/etc/ssh/sshd_config',
    line    => "PermitRootLogin ${permitrootlogin} # Edited by Puppet.",
    match   => '^#?[[:space:]]*PermitRootLogin[[:space:]]*.*$',
    require => Package['openssh-server'],
    notify  => Service['ssh'],
  }

  # With Ubuntu Trusty, "service ssh status" returns 0
  # even if the service is down.
  service { 'ssh':
    ensure     => running,
    hasrestart => true,
    status     => "netstat -lntp | grep -Eq '/sshd[[:space:]]*$'",
  }

}



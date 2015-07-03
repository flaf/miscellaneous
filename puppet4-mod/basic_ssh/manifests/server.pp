class basic_ssh::server (
  Enum['yes', 'without-password', 'forced-commands-only', 'no'] $permitrootlogin,
){

  ::homemade::is_supported_distrib(['trusty', 'jessie'], $title)

  ensure_packages(['openssh-server', ], { ensure => present, })

  file_line { 'edit-PermitRootLogin-parameter':
    path    => '/etc/ssh/sshd_config',
    line    => "PermitRootLogin ${permitrootlogin} # Edited by Puppet.",
    match   => '^#?[[:space:]]*PermitRootLogin[[:space:]]*.*$',
    require => Package['openssh-server'],
    notify  => Service['ssh'],
  }

  # With Ubuntu Trusty, "service ssh status" returns 0
  # even if the service is down. So, we need a specific
  # `status` command for this distribution.
  case $::lsbdistcodename {
    'trusty': {
      $status = "netstat -lntp | grep -Eq '/sshd[[:space:]]*$'"
    }
    default: {
      $status = undef
    }
  }

  service { 'ssh':
    ensure     => running,
    hasrestart => true,
    status     => $status,
  }

}



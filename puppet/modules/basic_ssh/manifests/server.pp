class basic_ssh::server {

  include '::basic_ssh::server::params'

  [
    $permitrootlogin,
    $port,
    $supported_distributions,
  ] = Class['::basic_ssh::server::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ensure_packages(['openssh-server', ], { ensure => present, })

  file_line { 'edit-PermitRootLogin-parameter':
    path    => '/etc/ssh/sshd_config',
    line    => "PermitRootLogin ${permitrootlogin} # Edited by Puppet.",
    match   => '^#?[[:space:]]*PermitRootLogin[[:space:]]*.*$',
    require => Package['openssh-server'],
    notify  => Service['ssh'],
  }

  file_line { 'edit-Piort-parameter':
    path    => '/etc/ssh/sshd_config',
    line    => "Port ${port} # Edited by Puppet.",
    match   => '^#?[[:space:]]*Port[[:space:]]*.*$',
    require => Package['openssh-server'],
    notify  => Service['ssh'],
  }

  # With Ubuntu Trusty, "service ssh status" returns 0
  # even if the service is down. So, we need a specific
  # `status` command for this distribution.
  case $::facts['os']['distro']['codename'] {
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



class httpproxy {

  include '::httproxy::params'

  [
   $apt_cacher_ng_adminpwd,
   $apt_cacher_ng_port,
  ] = Class['httpproxy::params']


  ### Apt-cacher-ng ###

  ensure_package(
    [
      'apt-cacher-ng',
      'ca-certificates', # Required to request HTTPS pages.
    ],
    {ensure => present}
  )

  file {'/etc/apt-cacher-ng/security.conf':
    owner   => 'apt-cacher-ng',
    group   => 'apt-cacher-ng',
    mode    => '0640',
    require => Package['apt-cacher-ng'],
    notify  => Service['apt-cacher-ng'],
    content => epp(
                 'httproxy/security.conf.epp',
                 {
                   'apt_cacher_ng_adminpwd' => $apt_cacher_ng_adminpwd,
                 },
               ),
  }

  file_line { 'edit-PermitRootLogin-parameter':
    path    => '/etc/ssh/sshd_config',
    line    => "Port:${apt_cacher_ng_port}",
    match   => '^#?[[:space:]]*Port:[0-9]+',
    require => Package['apt-cacher-ng'],
    notify  => Service['apt-cacher-ng'],
  }

  service { 'apt-cacher-ng':
    ensure     => running,
    hasrestart => true,
    hasstatus  => true,
  }


  ### The keyserver and the Puppet Forge API. ###

  ensure_package(
    [
      'nginx-light',
    ],
    {ensure => present}
  )


  file {
    default:
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['nginx'],
      notify  => Service['nginx'],
    ;

    '/etc/nginx/sites-available/keyserver':
      content => epp(
                   'httproxy/security.conf.epp',
                   {
                     'apt_cacher_ng_adminpwd' => $apt_cacher_ng_adminpwd,
                   },
      ;

  }

  service { 'nginx':
    ensure     => running,
    hasrestart => true,
    hasstatus  => true,
  }


}



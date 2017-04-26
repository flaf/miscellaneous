class httpproxy {

  include '::httpproxy::params'

  [
   $enable_apt_cacher_ng,
   $apt_cacher_ng_adminpwd,
   $apt_cacher_ng_port,
   #
   $enable_keyserver,
   $keyserver_fqdn,
   #
   $enable_puppetforgeapi,
   $puppetforgeapi_fqdn,
   $pgp_pubkeys,
   $keydir,
   $supported_distributions,
  ] = Class['httpproxy::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if $enable_apt_cacher_ng {
    ::homemade::fail_if_undef(
      $apt_cacher_ng_adminpwd,
      'httpproxy::params::apt_cacher_ng_adminpwd',
      $title
    )
  }

  ### The service Apt-cacher-ng. ###

  ensure_packages(
    [
      'apt-cacher-ng',
      'ca-certificates', # Required to request HTTPS pages.
    ],
    {ensure => present}
  )

  # If the service apt-cacher-ng is disabled, the password
  # can be undefined. In this case, we set a "demo" password
  # in the file below.
  $acng_adminpwd = $apt_cacher_ng_adminpwd.lest || { 'XXXXXX' }

  file {'/etc/apt-cacher-ng/security.conf':
    ensure  => 'file',
    owner   => 'apt-cacher-ng',
    group   => 'apt-cacher-ng',
    mode    => '0600',
    require => Package['apt-cacher-ng'],
    notify  => Service['apt-cacher-ng'],
    content => epp(
                 'httpproxy/security.conf.epp',
                 {
                   'apt_cacher_ng_adminpwd' => $acng_adminpwd,
                 },
               ),
  }

  file_line { 'edit-acng.conf':
    path    => '/etc/apt-cacher-ng/acng.conf',
    line    => "Port:${apt_cacher_ng_port}",
    match   => '^#?[[:space:]]*Port:[0-9]+',
    require => Package['apt-cacher-ng'],
    notify  => Service['apt-cacher-ng'],
  }

  service { 'apt-cacher-ng':
    ensure     => if $enable_apt_cacher_ng {'running'} else {'stopped'},
    enable     => $enable_apt_cacher_ng,
    hasrestart => true,
    hasstatus  => true,
  }


  ### The keyserver and the Puppet Forge API. ###

  ensure_packages(
    [
      'nginx-light',
    ],
    {ensure => present}
  )

  file {
    default:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['nginx-light'],
      notify  => Service['nginx'],
    ;
    '/etc/nginx/sites-enabled/default':
      ensure => 'absent',
    ;
    '/etc/nginx/sites-available/keyserver':
      content => epp(
                   'httpproxy/keyserver.epp',
                   {
                     'keyserver_fqdn' => $keyserver_fqdn,
                   },
                 )
    ;
    '/etc/nginx/sites-enabled/keyserver':
      ensure => if $enable_keyserver {'link'} else {'absent'},
      target => '../sites-available/keyserver',
    ;
    '/etc/nginx/sites-available/puppetforgeapi':
      content => epp(
                   'httpproxy/puppetforgeapi.epp',
                   {
                     'puppetforgeapi_fqdn' => $puppetforgeapi_fqdn,
                   },
                 ),
    ;
    '/etc/nginx/sites-enabled/puppetforgeapi':
      ensure => if $enable_puppetforgeapi {'link'} else {'absent'},
      target => '../sites-available/puppetforgeapi',
    ;
  }

  file {$keydir:
    ensure  => 'directory',
    recurse => true,
    purge   => true,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => Package['nginx-light'],
  }

  $pgp_pubkeys.each |$pubkey| {
    httpproxy::pgppublickeyfile {$pubkey['name']:
     id      => $pubkey['id'],
     content => $pubkey['content'],
     require => File[$keydir],
     before  => Service['nginx'],
    }
  }

  $enable_nginx = case [$enable_keyserver, $enable_puppetforgeapi] {
    [false, false]: { false }
    default:        { true  }
  }

  service { 'nginx':
    ensure     => if $enable_nginx {'running'} else {'stopped'},
    enable     => $enable_nginx,
    hasrestart => true,
    hasstatus  => true,
  }

}



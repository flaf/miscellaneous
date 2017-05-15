class httpproxy {

  include '::httpproxy::params'

  [
   $enable_apt_cacher_ng,
   $apt_cacher_ng_adminpwd,
   $apt_cacher_ng_port,
   #
   $enable_keyserver,
   $keyserver_fqdn,
   $pgp_pubkeys,
   $keydir,
   #
   $enable_puppetforgeapi,
   $puppetforgeapi_fqdn,
   #
   $enable_squidguard,
   $squid_allowed_networks,
   $squidguard_conf,
   $squidguard_admin_email,
   $forbiddendir,
   #
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
    '/etc/nginx/sites-available/forbidden':
      content => epp(
                   'httpproxy/forbidden.epp',
                   {
                     'server_name' => $::facts['networking']['ip'],
                     'root'        => $forbiddendir,
                   },
                 ),
    ;
    '/etc/nginx/sites-enabled/forbidden':
      ensure => if $enable_squidguard {'link'} else {'absent'},
      target => '../sites-available/forbidden',
    ;
  }

  file {
    default:
      ensure  => 'directory',
      recurse => true,
      purge   => true,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      require => Package['nginx-light'],
      before  => Service['nginx'],
    ;
    [$keydir, $forbiddendir]:
    ;
    "${forbiddendir}/forbidden.html":
      ensure  => 'file',
      mode    => '0644',
      content => epp(
                   'httpproxy/forbidden.html.epp',
                   {
                     'admin_email' => $squidguard_admin_email,
                     'fqdn'        => $::facts['networking']['fqdn'],
                   },
                 ),
    ;
  }

  $pgp_pubkeys.each |$pubkey| {
    httpproxy::pgppublickeyfile {$pubkey['name']:
     id      => $pubkey['id'],
     content => $pubkey['content'],
     require => File[$keydir],
     before  => Service['nginx'],
    }
  }

  $enable_nginx = case [$enable_keyserver, $enable_puppetforgeapi, $enable_squidguard] {
    [false, false, false]: { false }
    default              : { true  }
  }

  service { 'nginx':
    ensure     => if $enable_nginx {'running'} else {'stopped'},
    enable     => $enable_nginx,
    hasrestart => true,
    hasstatus  => true,
  }


  ### Squid and Squidguard. ###

  ensure_packages(
    [
      'squid',
      'squidguard',
    ],
    {ensure => present}
  )

  file { '/etc/squid/squid.conf':
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['squid'],
    notify  => Service['squid'],
    content => epp(
                 'httpproxy/squid.conf.epp',
                 {
                   'allowed_networks' => $squid_allowed_networks,
                 },
               ),
  }

  service { 'squid':
    ensure     => if $enable_squidguard {'running'} else {'stopped'},
    enable     => $enable_squidguard,
    hasrestart => true,
    hasstatus  => true,
  }

  # Squidguard should be configure only when Squid daemon is UP.
  file { '/etc/squidguard/squidGuard.conf':
    ensure  => 'file',
    owner   => 'proxy',
    group   => 'proxy',
    mode    => '0640',
    require => Service['squid'],
    notify  => Exec['update-squidguard'],
    content => epp(
                 'httpproxy/squidguard.conf.epp',
                 {
                   'conf' => $squidguard_conf,
                 },
               ),
  }

  # Creations of urls/domains lists.
  $squidguard_conf.each |$blocktype, $a_block| {
    $a_block.each |$name, $settings| {
      $settings.filter |$option, $value| {
        $option =~ Httpproxy::SquidguardList and $value =~ Array
      }.each |$option, $value| {

        $t = httpproxy::get_option_value($name, $option, $value).split('/')
        $f = "/var/lib/squidguard/db/${t[0]}/${t[1]}"
        $d = "/var/lib/squidguard/db/${t[0]}"

        file {
          default:
            owner   => 'proxy',
            group   => 'proxy',
            require => File['/etc/squidguard/squidGuard.conf'],
            notify  => Exec['update-squidguard'],
          ;
          $d:
            ensure => 'directory',
            mode   => '2750',
          ;
          $f:
            ensure  => 'file',
            mode    => '0644',
            content => epp(
                         'httpproxy/squidguardlist.epp',
                         {
                          'list' => $value,
                         },
                       ),
          ;
        }

      }
    }
  }

  exec { 'update-squidguard':
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'update-squidguard -v',
    refreshonly => true,
  }

}



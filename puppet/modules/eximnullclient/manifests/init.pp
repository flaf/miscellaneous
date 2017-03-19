class eximnullclient {

  include '::eximnullclient::params'

  [
   $dc_smarthost,
   $passwd_client,
   $redirect_local_mails,
   $prune_from,
   $supported_distributions,
  ] = Class['::eximnullclient::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $fqdn                = $::facts.dig("networking", "fqdn")
  $dc_other_hostnames  = [ $fqdn ]
  $dc_local_interfaces = [ '127.0.0.1', '::1' ]
  $dc_readhost         = $fqdn

  ensure_packages(
    [
      'exim4-daemon-light',
      'heirloom-mailx',
    ],
    { ensure => present },
  )

  $content_update_exim4_conf_conf = epp(
    'eximnullclient/update-exim4.conf.conf.epp',
    {
      'dc_other_hostnames'  => $dc_other_hostnames,
      'dc_local_interfaces' => $dc_local_interfaces,
      'dc_readhost'         => $dc_readhost,
      'dc_smarthost'        => $dc_smarthost,
    },
  )

  $content_aliases_virtual = epp(
    'eximnullclient/aliases.virtual.epp',
    {
      'fqdn'                 => $fqdn,
      'redirect_local_mails' => $redirect_local_mails,
    },
  )

  $content_router_exim4_config_header = epp(
    'eximnullclient/router/00_exim4-config_header.epp',
    {
      'redirect_local_mails' => $redirect_local_mails,
    },
  )

  $content_rewrite_exim4_config_header = epp(
    'eximnullclient/rewrite/00_exim4-config_header.epp',
    {
      'prune_from' => $prune_from,
    },
  )

  $content_passwd_client = epp(
    'eximnullclient/passwd.client.epp',
    {
      'passwd_client' => $passwd_client,
    },
  )

  file {
    default:
      ensure  => 'file',
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      require => Package['exim4-daemon-light'],
      notify  => Exec['update-exim4.conf'],
    ;

    '/etc/exim4/update-exim4.conf.conf':
      content => $content_update_exim4_conf_conf,
    ;

    '/etc/exim4/aliases.virtual':
      content => $content_aliases_virtual,
    ;

    '/etc/exim4/conf.d/router/00_exim4-config_header':
      content => $content_router_exim4_config_header,
    ;

    '/etc/exim4/conf.d/rewrite/00_exim4-config_header':
      content => $content_rewrite_exim4_config_header,
    ;

    '/etc/exim4/passwd.client':
      group   => 'Debian-exim',
      mode    => '0640',
      content => $content_passwd_client,
    ;
  }

  exec { 'update-exim4.conf':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'update-exim4.conf',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    notify      => Service['exim4'],
  }

  service { 'exim4':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
  }

}



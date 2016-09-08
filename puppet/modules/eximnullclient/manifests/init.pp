class eximnullclient {

  $params = '::eximnullclient::params'
  include $params

  $dc_smarthost            = ::homemade::getvar("${params}::dc_smarthost", $title)
  $redirect_local_mails    = ::homemade::getvar("${params}::redirect_local_mails", $title)
  $prune_from              = ::homemade::getvar("${params}::prune_from", $title)
  $supported_distributions = ::homemade::getvar("${params}::supported_distributions", $title)

  $fqdn                = $::facts.dig("networking", "fqdn")
  $dc_other_hostnames  = [ $fqdn ]
  $dc_local_interfaces = [ '127.0.0.1', '::1' ]
  $dc_readhost         = $fqdn

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ensure_packages( [
                    'exim4-daemon-light',
                    'heirloom-mailx',
                   ], { ensure => present }
                 )

  file { '/etc/exim4/update-exim4.conf.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['exim4-daemon-light'],
    notify  => Exec['update-exim4.conf'],
    content => epp( 'eximnullclient/update-exim4.conf.conf.epp',
                    {
                      'dc_other_hostnames'  => $dc_other_hostnames,
                      'dc_local_interfaces' => $dc_local_interfaces,
                      'dc_readhost'         => $dc_readhost,
                      'dc_smarthost'        => $dc_smarthost,
                    }
                  ),
  }

  file { '/etc/exim4/aliases.virtual':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['exim4-daemon-light'],
    notify  => Exec['update-exim4.conf'],
    content => epp( 'eximnullclient/aliases.virtual.epp',
                    {
                      'fqdn'                 => $fqdn,
                      'redirect_local_mails' => $redirect_local_mails,
                    }
                  ),
  }

  file { '/etc/exim4/conf.d/router/00_exim4-config_header':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['exim4-daemon-light'],
    notify  => Exec['update-exim4.conf'],
    content => epp( 'eximnullclient/router/00_exim4-config_header.epp',
                    {
                      'redirect_local_mails' => $redirect_local_mails,
                    }
                  ),
  }

  file { '/etc/exim4/conf.d/rewrite/00_exim4-config_header':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['exim4-daemon-light'],
    notify  => Exec['update-exim4.conf'],
    content => epp( 'eximnullclient/rewrite/00_exim4-config_header.epp',
                    {
                      'prune_from' => $prune_from,
                    }
                  ),
  }

  exec { 'update-exim4.conf':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'update-exim4.conf',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    notify      => Service['exim4'],
    require     => [
                    File['/etc/exim4/update-exim4.conf.conf'],
                    File['/etc/exim4/aliases.virtual'],
                    File['/etc/exim4/conf.d/router/00_exim4-config_header'],
                    File['/etc/exim4/conf.d/rewrite/00_exim4-config_header'],
                   ],
  }

  service { 'exim4':
    ensure     => running,
    enable     => true,
    hasrestart => true,
    hasstatus  => true,
    require    => Exec['update-exim4.conf'],
  }

}


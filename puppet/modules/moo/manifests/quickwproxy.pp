class moo::quickwproxy {

  include 'moo::quickwproxy::params'

  [
    $listen,
    $public_domain,
    $proxy_pass_address,
    $ssl_cert,
    $ssl_key,
    $supported_distributions,
  ] = Class['moo::quickwproxy::params']

  $ssl_cert_name = 'ssl-certificate.pem'
  $ssl_key_name  = 'ssl-private-key.pem'

  ::homemade::is_supported_distrib($supported_distributions, $title)
  ::homemade::fail_if_undef($ssl_cert, 'moo::quickwproxy::ssl_cert', $title)
  ::homemade::fail_if_undef($ssl_key, 'moo::quickwproxy::ssl_key', $title)

  ensure_packages(['nginx-light'], { ensure => present })

  file { '/etc/nginx/sites-available/default':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['nginx-light'],
    notify  => Service['nginx'],
    content => epp( 'moo/quickconf_nginx.conf.epp',
                    {
                      'listen'             => $listen,
                      'public_domain'      => $public_domain,
                      'proxy_pass_address' => $proxy_pass_address,
                      'ssl_cert_name'      => $ssl_cert_name,
                      'ssl_key_name'       => $ssl_key_name,
                    },
                  ),
  }

  file { "/etc/nginx/${ssl_cert_name}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => Package['nginx-light'],
    notify  => Service['nginx'],
    content => $ssl_cert,
  }

  file { "/etc/nginx/${ssl_key_name}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Package['nginx-light'],
    notify  => Service['nginx'],
    content => $ssl_key,
  }

  service { 'nginx':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }

}


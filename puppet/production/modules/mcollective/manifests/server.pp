class mcollective::server (
) {

  $packages = [
               'ruby-stomp',
               'mcollective',
              ]

  ensure_packages($packages, { ensure => present, })

  #file { '/etc/mcollective/server.cfg':
  #  ensure  => present,
  #  #owner   => 'root',
  #  #group   => 'root',
  #  #mode    => '0644',
  #  content => template('mcollective/server.cfg.erb'),
  #  require => Package['mcollective'],
  #  before  => Service['mcollective'],
  #  notify  => Service['mcollective'],
  #}

  #service { 'mcollective':
  #  ensure     => running,
  #  hasstatus  => true,
  #  hasrestart => true,
  #}

}



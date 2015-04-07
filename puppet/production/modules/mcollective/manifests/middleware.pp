class mcollective::middleware {

  ensure_packages( [ 'rabbitmq-server' ], { ensure => present, })

  file { '/etc/rabbitmq/rabbitmq.config':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mcollective/rabbitmq.config.erb'),
    require => Package['rabbitmq-server'],
    before  => Service['rabbitmq'],
    notify  => Service['rabbitmq'],
  }

  service { 'rabbitmq':
    name       => 'rabbitmq-server',
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }

}



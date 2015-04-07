class mcollective::middleware {

  $packages = [ 'rabbitmq-server', 'python', ]
  $cmd_cli  = "/var/lib/rabbitmq/mnesia/rabbit@*-plugins-expand/\
rabbitmq_management-*/priv/www/cli/rabbitmqadmin"

  ensure_packages($packages, { ensure => present, })

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

  file { '/etc/rabbitmq/enabled_plugins':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('mcollective/enabled_plugins.erb'),
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

  exec { 'install-cli-mgt':
    command => "cp ${cmd_cli} /usr/local/sbin/",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => 'test -f /usr/local/sbin/rabbitmqadmin',
    require  => Service['rabbitmq'],
  }

  file { '/usr/local/sbin/rabbitmqadmin':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0754',
    require => Exec['install-cli-mgt'],
  }

}



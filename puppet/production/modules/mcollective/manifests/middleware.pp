class mcollective::middleware (
  $mgt_ip         = '127.0.0.1',
  $mgt_port       = 15672,
  $stomp_ssl_ip   = '0.0.0.0',
  $stomp_ssl_port = 61614,
  $puppet_ssl_dir = '/var/lib/puppet/ssl',
) {

  $packages = [
                'rabbitmq-server',
                'python',          # Needed for the cli rabbitmqadmin.
              ]
  $ssl_dir  = '/etc/rabbitmq/ssl'
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

  file { $ssl_dir:
    ensure => directory,
    owner  => 'rabbitmq',
    group  => 'rabbitmq',
    mode   => '0500',
    before => Service['rabbitmq'],
    notify => Service['rabbitmq'],
  }

  file { [
           "${ssl_dir}/cacert.pem",
           "${ssl_dir}/cert.pem",
           "${ssl_dir}/key.pem",
         ]:
    ensure => present,
    owner  => 'rabbitmq',
    group  => 'rabbitmq',
    mode   => '0400',
    before => Service['rabbitmq'],
    notify => Service['rabbitmq'],
  }

  exec { 'rabbitmq-update-private.pem':
    command => "cat '${puppet_ssl_dir}/private_keys/${::fqdn}.pem' >'${ssl_dir}/key.pem'",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "diff -q '${puppet_ssl_dir}/private_keys/${::fqdn}.pem' '${ssl_dir}/key.pem'",
    require => File[$ssl_dir],
    before  => Service['rabbitmq'],
    notify  => Service['rabbitmq'],
  }

  exec { 'rabbitmq-update-cert.pem':
    command => "cat '${puppet_ssl_dir}/certs/${::fqdn}.pem' >'${ssl_dir}/cert.pem'",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "diff -q '${puppet_ssl_dir}/certs/${::fqdn}.pem' '${ssl_dir}/cert.pem'",
    require => File[$ssl_dir],
    before  => Service['rabbitmq'],
    notify  => Service['rabbitmq'],
  }

  exec { 'rabbitmq-update-cacert.pem':
    command => "cat '${puppet_ssl_dir}/certs/ca.pem' >'${ssl_dir}/cacert.pem'",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "diff -q '${puppet_ssl_dir}/certs/ca.pem' '${ssl_dir}/cacert.pem'",
    require => File[$ssl_dir],
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

  exec { 'declare-vhost-mcollective':
    command => "rabbitmqadmin declare vhost name=/mcollective",
    path    => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "rabbitmqadmin list vhosts | grep -q ' /mcollective '",
    require  => File['/usr/local/sbin/rabbitmqadmin'],
  }

}



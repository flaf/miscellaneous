class mcollective::middleware (
  $mgt_ip          = '127.0.0.1',
  $mgt_port        = 15672,
  $stomp_ssl_ip    = '0.0.0.0',
  $stomp_ssl_port  = 61614,
  $puppet_ssl_dir  = '/var/lib/puppet/ssl',
  $admin_pwd       = md5("${::fqdn}-admin"),
  $mcollective_pwd = md5("${::fqdn}-mcollective"),
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

  $cmd_in_path = '/usr/local/sbin/rabbitmqadmin'

  exec { 'install-cli-mgt':
    command => "cp ${cmd_cli} /usr/local/sbin/",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "test -f ${cmd_in_path} && diff -q  ${cmd_cli} ${cmd_in_path}",
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
    require => File['/usr/local/sbin/rabbitmqadmin'],
  }

  # No, it seems that RabbitMQ needs to the "/" vhost to
  # work correctly.
  #
  #exec { 'remove-vhost-root':
  #  command => "rabbitmqadmin delete vhost name=/",
  #  path    => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
  #  user    => 'root',
  #  group   => 'root',
  #  onlyif  => "rabbitmqadmin list vhosts | grep -q ' / '",
  #  require => Exec['declare-vhost-mcollective'],
  #}

  # This file will be managed via file_line and
  # ini_setting resources. This file is a way to
  # manage and update passwords of the RabbitMQ accounts
  # (admin and mcollective).
  file { '/root/.rabbitmq.cnf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Exec['declare-vhost-mcollective'],
  }

  file_line { 'add-comment':
    path    => '/root/.rabbitmq.cnf',
    line    => "# This file is edited by Puppet, don't edit it.",
    require => File['/root/.rabbitmq.cnf'],
  }

  # This commands are idempotent. No error if the user
  # already exists.
  $cmd_set_admin       = "rabbitmqadmin declare user name=admin \
password='${admin_pwd}' tags=administrator"
  $cmd_set_mcollective = "rabbitmqadmin declare user name=mcollective \
password='${mcollective_pwd}' tags="

  ini_setting { 'put-pwd-admin':
    path    => '/root/.rabbitmq.cnf',
    ensure  => present,
    section => 'admin',
    setting => 'password',
    value   => $admin_pwd,
    require => File_line['add-comment'],
    notify  => Exec['set-admin-account'],
  }

  exec { 'set-admin-account':
    command     => $cmd_set_admin,
    path        => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
    user        => 'root',
    group       => 'root',
    require     => Ini_setting['put-pwd-admin'],
    refreshonly => true,
  }

  ini_setting { 'put-pwd-mcollective':
    path    => '/root/.rabbitmq.cnf',
    ensure  => present,
    section => 'mcollective',
    setting => 'password',
    value   => $mcollective_pwd,
    require => File_line['add-comment'],
    notify  => Exec['set-mcollective-account'],
  }

  exec { 'set-mcollective-account':
    command     => $cmd_set_mcollective,
    path        => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
    user        => 'root',
    group       => 'root',
    require     => Ini_setting['put-pwd-mcollective'],
    refreshonly => true,
  }

  exec { 'remove-guest-account':
    command => "rabbitmqadmin delete user name=guest",
    path    => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    onlyif  => "rabbitmqadmin list users | grep -q ' guest '",
    require => Ini_setting['put-pwd-mcollective'],
  }

#rabbitmqadmin declare permission vhost=/mcollective user=mcollective configure='.*' write='.*
#rabbitmqadmin declare permission vhost=/mcollective user=admin configure='.*' write='.*' read
#
## Bizarre de faire une boucle for pour ça...
#for collective in mcollective
#do
#    rabbitmqadmin declare exchange --user=admin --password=$pwd --vhost=/mcollective name=${c
#done

}



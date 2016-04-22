class mcomiddleware  {

  $params = '::mcomiddleware::params'
  include $params
  $stomp_ssl_ip    = ::homemade::getvar("${params}::stomp_ssl_ip",    $title)
  $stomp_ssl_port  = ::homemade::getvar("${params}::stomp_ssl_port",  $title)
  $ssl_versions    = ::homemade::getvar("${params}::ssl_versions",    $title)
  $puppet_ssl_dir  = ::homemade::getvar("${params}::puppet_ssl_dir",  $title)
  $admin_pwd       = ::homemade::getvar("${params}::admin_pwd",       $title)
  $mcollective_pwd = ::homemade::getvar("${params}::mcollective_pwd", $title)
  $exchanges       = ::homemade::getvar("${params}::exchanges",       $title)

  $packages = [ 'rabbitmq-server',
                'python',          # Needed for the cli rabbitmqadmin.
              ]
  $ssl_dir  = '/etc/rabbitmq/ssl'

  ensure_packages($packages, { ensure => present, })

  file { '/etc/rabbitmq/rabbitmq.config':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp( 'mcomiddleware/rabbitmq.config.epp',
                    { 'stomp_ssl_ip'   => $stomp_ssl_ip,
                      'stomp_ssl_port' => $stomp_ssl_port,
                      'ssl_versions'   => $ssl_versions,
                    }
                  ),
    require => Package['rabbitmq-server'],
    before  => Service['rabbitmq'],
    notify  => Service['rabbitmq'],
  }

  file { '/etc/rabbitmq/enabled_plugins':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('mcomiddleware/enabled_plugins.epp'),
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

  file { [ "${ssl_dir}/cacert.pem",
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
  $cmd_cli     = "/var/lib/rabbitmq/mnesia/rabbit@*-plugins-expand/\
rabbitmq_management-*/priv/www/cli/rabbitmqadmin"

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

  # Now, the daemon is UP and the rabbitmqadmin command
  # is available. Just after the first installation, the
  # admin account is "guest" with the password "guest".
  # This is the default account used by the rabbitmqadmin
  # command if there is no ~/.rabbitmqadmin.conf file.

  # We can't manage this file directly because this file must
  # have the good admin password at every instant. Thus, the
  # update of the admin password in RabbitMQ and the update
  # of this conf file must be atomic (in just one exec).
  file { '/root/.rabbitmqadmin.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => File['/usr/local/sbin/rabbitmqadmin'],
  }

  # But we will manage the .puppet version of the file above.
  # If this file changes, it is necessarily the admin password
  # or the mcollective password. In this case, an update is
  # necessary. But the admin account is special because, this
  # account will be used by the rabbitmqadmin command.
  file { '/root/.rabbitmqadmin.conf.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => epp( 'mcomiddleware/rabbitmqadmin.conf.epp',
                    { 'admin_pwd'       => $admin_pwd,
                      'mcollective_pwd' => $mcollective_pwd,
                      'ssl_dir'         => $ssl_dir,
                    }
                  ),
    require => File['/root/.rabbitmqadmin.conf'],
    notify  => [ Exec['create-update-admin-account-and-push-new-conf'],
                 Exec['update-mcollective-account'],
               ],
  }

  # It seems to me that if the rabbitmqadmin commands are
  # launched just after the restart of the service, there
  # are risk of errors. I think the `sleep 0.5` command
  # decreases the risk.
  $rbmqadm = 'sleep 0.5 && rabbitmqadmin --config="/root/.rabbitmqadmin.conf"'

  # Creation/update of the admin account and update of the
  # /root/.rabbitmqadmin.conf file. Indeed, the 2 actions
  # must be atomic because the rabbitmqadmin command uses
  # this file for the connection.
  $cmd_set_admin = "${rbmqadm} declare user name=admin \
password='${admin_pwd}' tags=administrator && \
cat /root/.rabbitmqadmin.conf.puppet > /root/.rabbitmqadmin.conf"

  # This command is idempotent. No error if the user
  # already exists. We ensure that the HOME environment
  # variable is set to use the default and implicit option
  # --config=~/.rabbitmqadmin.conf. Thus, if the file exists
  # and it is well provisioned (it contains the right
  # password of the admin account), the rabbitmqadmin
  # command will use the admin account with its password. If
  # the file doesn't exist (for instance during the first
  # installation), the rabbitmqadmin command will use the
  # default account "guest" with the default password
  # "guest".
  $cmd_set_mcollective = "${rbmqadm} declare user \
name=mcollective password='${mcollective_pwd}' tags="

  exec { 'create-update-admin-account-and-push-new-conf':
    command     => $cmd_set_admin,
    path        => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
    user        => 'root',
    group       => 'root',
    require     => File['/root/.rabbitmqadmin.conf.puppet'],
    refreshonly => true,
    alias       => 'conf-admin-ok',
  }

  # After this exec we are sure that the conf file is OK
  # relative to the admin password.
  # For the rest, I have followed this page:
  # https://docs.puppetlabs.com/mcollective/reference/plugins/connector_rabbitmq.html

  exec { 'create-mcollective-account':
    command => $cmd_set_mcollective,
    path    => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    require => Exec['conf-admin-ok'],
    unless  => "${rbmqadm} list users | grep -q ' mcollective '",
  }

  exec { 'update-mcollective-account':
    command     => $cmd_set_mcollective,
    path        => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
    user        => 'root',
    group       => 'root',
    require     => Exec['conf-admin-ok'],
    refreshonly => true,
  }

  exec { 'remove-guest-account':
    command => "${rbmqadm} delete user name=guest",
    path    => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    onlyif  => "${rbmqadm} list users | grep -q ' guest '",
    require => Exec['conf-admin-ok'],
  }

  exec { 'declare-vhost-mcollective':
    command => "${rbmqadm} declare vhost name=/mcollective",
    path    => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "${rbmqadm} list vhosts | grep -q ' /mcollective '",
    require => Exec['conf-admin-ok'],
  }

  # No, it seems that RabbitMQ needs to the "/" vhost to
  # work correctly.
  #exec { 'remove-vhost-root':
  #  command => "rabbitmqadmin delete vhost name=/",
  #  path    => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
  #  user    => 'root',
  #  group   => 'root',
  #  onlyif  => "rabbitmqadmin list vhosts | grep -q ' / '",
  #  require => Exec['conf-admin-ok'],
  #}

  $cmd_perm = "${rbmqadm} declare permission vhost=/mcollective \
user=mcollective configure='.*' write='.*' read='.*'
${rbmqadm} declare permission vhost=/mcollective \
user=admin configure='.*' write='.*' read='.*'"

  exec { 'declare-permissions':
    command => $cmd_perm,
    path    => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "${rbmqadm} list permissions | grep -q ' /mcollective '",
    require => Exec['declare-vhost-mcollective'],
  }

  # Creation of exchanges.

  # If not present, we add the 'mcollective' exchange.
  $exchanges_final_value = $exchanges.concat('mcollective').unique()

  $cmd_exchange = @("END")
    ${rbmqadm} declare exchange --vhost=/mcollective name=EXCHANGE_broadcast type=topic
    ${rbmqadm} declare exchange --vhost=/mcollective name=EXCHANGE_directed type=direct
    |- END

  $sp    = '[[:space:]]+' # regex for spaces.
  $regex = '\|_SP_/mcollective_SP_\|_SP_EXCHANGE_(broadcast|directed)_SP_\|'.regsubst('_SP_', $sp, 'G')

  $unless_cmd_exchange = "test $(${rbmqadm} list exchanges | grep -Ec '${regex}') = 2"

  $exchanges_final_value.each |$an_exchange| {
    exec { "declare-exchanges-${an_exchange}":
      command => $cmd_exchange.regsubst('EXCHANGE', $an_exchange, 'G'),
      path    => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
      user    => 'root',
      group   => 'root',
      unless  => $unless_cmd_exchange.regsubst('EXCHANGE', $an_exchange, 'G'),
      require => Exec['declare-permissions'],
    }
  }

}



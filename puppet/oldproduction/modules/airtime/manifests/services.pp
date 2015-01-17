class airtime::services {

  require 'airtime::params'
  $postgre_pass  = $airtime::params::postgre_pass
  $rabbitmq_pass = $airtime::params::rabbitmq_pass

  exec { 'change-postgre-pass':
    user        => 'postgres',
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    command     => "echo \"ALTER USER airtime WITH ENCRYPTED PASSWORD '$postgre_pass'\" | psql",
    refreshonly => true,
  }

  ->

  exec { 'change-rabbitmq-pass':
    user        => 'root',
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    command     => "rabbitmqctl change_password airtime '$rabbitmq_pass'",
    refreshonly => true,
  }

  ->

  exec { 'update-db-settings':
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    command     => 'airtime-update-db-settings',
    refreshonly => true,
  }

  ->

  service { 'airtime-liquidsoap':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }

  ->

  service { 'airtime-media-monitor':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }

  ->

  service { 'airtime-playout':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }

}



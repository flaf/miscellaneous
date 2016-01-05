class moo::captain (
  String[1]           $mysql_rootpwd,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  require '::moo::common'
  $mysql_moobotpwd = $::moo::common::moobot_db_pwd
  ensure_packages( [ 'mysql-server' ], { ensure => present } )

  file { '/root/init-moobot-database.sql':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    require => Package['mysql-server'],
    content => epp('moo/init-moobot-database.sql.epp',
                   {
                     'mysql_moobotpwd'  => $mysql_moobotpwd,
                     'mysql_rootpwd'    => $mysql_rootpwd,
                   }
                  )
  }

  exec { 'init-moobot-database':
    command => 'mysql < /root/init-moobot-database.sql',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    cwd     => '/root',
    user    => 'root',
    group   => 'root',
    unless  => 'true', # In fact this exec will be never launched. Too dangerous.
    require => File['/root/init-moobot-database.sql'],
  }

  file { '/root/.my.cnf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    require => Exec['init-moobot-database'],
    content => epp('moo/my.cnf.epp',
                   {
                     'mysql_rootpwd' => $mysql_rootpwd,
                   }
                  )
  }

  $address = $::facts['networking']['ip']

  $content = @("END")
    [mysqld]
    # It's better that MySQL uses any address of the system
    # (which includes the loopback address).
    bind-address = 0.0.0.0
    # Turn off MySQL reverse DNS lookup.
    skip-name-resolve = 1

    | END

  file { '/etc/mysql/conf.d/99-custom.cnf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => File['/root/.my.cnf'],
    content => $content,
    notify  => Service['mysql'],
  }

  service { 'mysql':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    require    => File['/etc/mysql/conf.d/99-custom.cnf'],
  }

}



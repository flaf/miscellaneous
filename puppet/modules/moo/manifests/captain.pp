class moo::captain (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  include '::moo::captain::params'

  $moobot_conf     = $::moo::captain::params::moobot_conf
  $mysql_rootpwd   = $::moo::captain::params::mysql_rootpwd
  $backup_cmd      = $::moo::captain::params::backup_cmd
  $mysql_moobotpwd = $moobot_conf['database']['password']

  class { '::moo::common':
    moobot_conf => $moobot_conf,
  }

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
    # No risk. No automatic execution of this command in any case.
    #command => 'mysql < /root/init-moobot-database.sql',
    command => 'true',
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

  cron { 'cron-backup-captain-db':
    ensure  => present,
    user    => 'root',
    command => $backup_cmd,
    hour    => 1,
    minute  => 0,
    require => Class['::moo::common'],
  }

}



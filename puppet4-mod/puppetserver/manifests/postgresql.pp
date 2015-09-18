class puppetserver::postgresql {

  require '::repository::postgresql'
  ensure_packages([ 'postgresql-9.4', 'postgresql-contrib-9.4' ], { ensure => present, })

  $db   = $::puppetserver::puppetdb_name
  $user = $::puppetserver::puppetdb_user
  $pwd  = $::puppetserver::puppetdb_pwd
  $warn = "# This file is managed by Puppet, don't edit it."


  file { 'postgresdb-init-file':
    path   => '/usr/local/sbin/postgresdb-init.puppet',
    ensure => present,
    owner  => 'root',
    group  => 'postgres',
    mode   => '0754',
    source => 'puppet:///modules/puppetserver/postgresdb-init.puppet',
  }

  # With this file, root can connect to the puppetdb with the
  # puppetdb user without input the password, just with:
  #
  #   psql --host localhost $db $user
  #
  # This is this file that puppet will use to know, for
  # instance, if the password must be updated.
  file { '/root/.pgpass':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => "${warn}\n\nlocalhost:5432:${db}:${user}:${pwd}\n\n",
    notify  => Exec['postgresdb-init']
  }

  exec { 'postgresdb-init':
    command     => "postgresdb-init.puppet '${user}' '${db}' '${pwd}'",
    path        => '/usr/local/sbin:/usr/sbin:/usr/bin:/sbin:/bin',
    user        => 'postgres',
    group       => 'postgres',
    refreshonly => true,
    require     => [
                     File['postgresdb-init-file'],
                     File['/root/.pgpass'],
                   ],
  }

}



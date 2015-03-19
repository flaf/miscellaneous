class puppetmaster::postgresql {

  private("Sorry, ${title} is a private class.")

  $db   = $::puppetmaster::puppetdb
  $user = $::puppetmaster::puppetdb_user
  $pwd  = $::puppetmaster::puppetdb_pwd
  $warn = "# This file is managed by Puppet, don't edit it."

  file { 'postgresdb-init-file':
    path   => '/usr/local/sbin/postgresdb_init',
    ensure => present,
    owner  => 'root',
    group  => 'postgres',
    mode   => '0754',
    source => 'puppet:///modules/puppetmaster/postgresdb_init',
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
    command     => "/usr/local/sbin/postgresdb_init '${user}' '${db}' '${pwd}'",
    path        => '/usr/local/bin:/usr/bin:/bin',
    user        => 'postgres',
    group       => 'postgres',
    refreshonly => true,
    require     => [
                     File['postgresdb-init-file'],
                     File['/root/.pgpass'],
                   ],
  }


}




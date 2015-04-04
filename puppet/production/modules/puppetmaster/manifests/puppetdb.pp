class puppetmaster::puppetdb {

  private("Sorry, ${title} is a private class.")

  $db   = $::puppetmaster::puppetdb_dbname
  $user = $::puppetmaster::puppetdb_user
  $pwd  = $::puppetmaster::puppetdb_pwd
  $file = '/etc/puppetdb/conf.d/database.ini'

  # The file will be modified via ini_setting resources.
  # Here, we just ensure the unix rights.
  file { $file:
    ensure => present,
    owner  => 'puppetdb',
    group  => 'puppetdb',
    mode   => '0640',
    before => Service['puppetdb'],
    notify => Service['puppetdb'],
  }

  ini_setting { 'set-classname':
    path    => $file,
    ensure  => present,
    section => 'database',
    setting => 'classname',
    value   => 'org.postgresql.Driver',
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  ini_setting { 'set-subprotocol':
    path    => $file,
    ensure  => present,
    section => 'database',
    setting => 'subprotocol',
    value   => 'postgresql',
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  ini_setting { 'set-subname':
    path    => $file,
    ensure  => present,
    section => 'database',
    setting => 'subname',
    value   => "//localhost:5432/${db}",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  ini_setting { 'set-username':
    path    => $file,
    ensure  => present,
    section => 'database',
    setting => 'username',
    value   => "${user}",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  ini_setting { 'set-password':
    path    => $file,
    ensure  => present,
    section => 'database',
    setting => 'password',
    value   => "${pwd}",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  service { 'puppetdb':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }

}



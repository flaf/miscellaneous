class puppetmaster::puppetdb {

  private("Sorry, ${title} is a private class.")

  $ca_server    = $::puppetmaster::ca_server
  $db           = $::puppetmaster::puppetdb_dbname
  $user         = $::puppetmaster::puppetdb_user
  $pwd          = $::puppetmaster::puppetdb_pwd
  $database_ini = '/etc/puppetdb/conf.d/database.ini'

  # The file will be modified via ini_setting resources.
  # Here, we just ensure the unix rights.
  file { $database_ini:
    ensure => present,
    owner  => 'puppetdb',
    group  => 'puppetdb',
    mode   => '0640',
    before => Service['puppetdb'],
    notify => Service['puppetdb'],
  }

  ini_setting { 'set-classname':
    path    => $database_ini,
    ensure  => present,
    section => 'database',
    setting => 'classname',
    value   => 'org.postgresql.Driver',
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  ini_setting { 'set-subprotocol':
    path    => $database_ini,
    ensure  => present,
    section => 'database',
    setting => 'subprotocol',
    value   => 'postgresql',
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  ini_setting { 'set-subname':
    path    => $database_ini,
    ensure  => present,
    section => 'database',
    setting => 'subname',
    value   => "//localhost:5432/${db}",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  ini_setting { 'set-username':
    path    => $database_ini,
    ensure  => present,
    section => 'database',
    setting => 'username',
    value   => "${user}",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  ini_setting { 'set-password':
    path    => $database_ini,
    ensure  => present,
    section => 'database',
    setting => 'password',
    value   => "${pwd}",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  $puppetdb_ssl = '/etc/puppetdb/ssl'
  $puppet_ssl   = '/var/lib/puppet/sslclient'

  file { [
           "${puppetdb_ssl}/ca.pem",
           "${puppetdb_ssl}/public.pem",
           "${puppetdb_ssl}/private.pem",
         ]:
    ensure => present,
    owner  => 'puppetdb',
    group  => 'puppetdb',
    mode   => '0640',
    before => Service['puppetdb'],
    notify => Service['puppetdb'],
  }

  if $ca_server != '<my-self>' {

    # The server isn't the CA, so we must use the certificate etc.
    # in /var/lib/puppet/sslclient/.

    # Note
    #
    # It was possible to do something like that:
    #
    #    file { "${puppetdb_ssl}/private.pem" :
    #
    #      ensure => present,
    #      owner  => 'puppetdb',
    #      group  => 'puppetdb',
    #      mode   => '0640',
    #      before => Service['puppetdb'],
    #      notify => Service['puppetdb'],
    #
    #      # Yes, with the attribute "source", we can put
    #      # a path of a local file (the syntax "puppet:///<module>/xxx"
    #      # is not the only allowed syntax).
    #      source => "${puppet_ssl}/private_keys/${::fqdn}.pem",
    #
    #    }
    #
    # But in this case, the content of the file appears in the
    # working directory of puppet (in /var/lib/puppet/) which it
    # bothers me a little. So I prefer some "exec" resources.

    exec { 'puppetdb-update-private.pem':
      command => "cat '${puppet_ssl}/private_keys/${::fqdn}.pem' >'${puppetdb_ssl}/private.pem'",
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      user    => 'root',
      group   => 'root',
      unless  => "diff -q '${puppet_ssl}/private_keys/${::fqdn}.pem' '${puppetdb_ssl}/private.pem'",
      before  => Service['puppetdb'],
      notify  => Service['puppetdb'],
    }

    exec { 'puppetdb-update-ca.pem':
      command => "cat '${puppet_ssl}/certs/ca.pem' >'${puppetdb_ssl}/ca.pem'",
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      user    => 'root',
      group   => 'root',
      unless  => "diff -q '${puppet_ssl}/certs/ca.pem' '${puppetdb_ssl}/ca.pem'",
      before  => Service['puppetdb'],
      notify  => Service['puppetdb'],
    }

    exec { 'puppetdb-update-public.pem':
      command => "cat '${puppet_ssl}/certs/${::fqdn}.pem' >'${puppetdb_ssl}/public.pem'",
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      user    => 'root',
      group   => 'root',
      unless  => "diff -q '${puppet_ssl}/certs/${::fqdn}.pem' '${puppetdb_ssl}/public.pem'",
      before  => Service['puppetdb'],
      notify  => Service['puppetdb'],
    }

  }

  service { 'puppetdb':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }

}



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

  # If the puppetmaster is CA, puppetdb will use certificates
  # in /var/lib/puppet/ssl, else in /var/lib/puppet/sslclient.
  if $ca_server != '<myself>' {

    # The puppetmaster is not CA.
    $puppet_ssl = '/var/lib/puppet/sslclient'
    $crl_file   = "${puppet_ssl}/crl.pem"

   } else {

    # The puppetmaster is CA.
    $puppet_ssl = '/var/lib/puppet/ssl'
    $crl_file   = "${puppet_ssl}/ca/ca_crl.pem"

   }

  file { [
           "${puppetdb_ssl}/ca.pem",
           "${puppetdb_ssl}/public.pem",
           "${puppetdb_ssl}/private.pem",
           "${puppetdb_ssl}/crl.pem",
         ]:
    ensure => present,
    owner  => 'puppetdb',
    group  => 'puppetdb',
    mode   => '0640',
    before => Service['puppetdb'],
    notify => Service['puppetdb'],
  }

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

  exec { 'puppetdb-update-crl.pem':
    command => "cat '${crl_file}' >'${puppetdb_ssl}/crl.pem'",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "diff -q '${crl_file}' '${puppetdb_ssl}/crl.pem'",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  # TODO: there is a problem! It seems that puppetdb (jetty in fact)
  # can't use the CRL of the CA (like apache). Normally, puppetdb
  # should have an updated CRL and should restart if the CRL has
  # changed.

  service { 'puppetdb':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }

}



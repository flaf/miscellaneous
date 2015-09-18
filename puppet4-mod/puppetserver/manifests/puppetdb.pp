class puppetserver::puppetdb {

  require '::repository::puppet'
  ensure_packages(['puppetdb'], { ensure => present, })

  $db           = $::puppetserver::puppetdb_name
  $user         = $::puppetserver::puppetdb_user
  $pwd          = $::puppetserver::puppetdb_pwd
  $memory       = $::puppetserver::puppetdb_memory
  $ca_myself    = $::puppetserver::ca_myself

  if $ca_myself {
    $puppet_ssl_dir = '/etc/puppetlabs/puppet/ssl'
  } else {
    $puppet_ssl_dir = '/etc/puppetlabs/puppet/sslagent'
  }
  $puppetdb_ssl_dir = '/etc/puppetlabs/puppetdb/ssl'

  # Set the memory for the JVM which runs the puppetdb.
  $java_args = "-Xmx${memory}"

  file_line { 'set-memory-to-puppetdb-jvm':
    path   => '/etc/default/puppetdb',
    line   => "JAVA_ARGS=\"${java_args}\" # line edited by Puppet.",
    match  => '^JAVA_ARGS=.*$',
    before => Service['puppetdb'],
    notify => Service['puppetdb'],
  }

  file { '/etc/puppetlabs/puppetdb/conf.d/database.ini':
    ensure  => present,
    owner   => 'puppetdb',
    group   => 'puppetdb',
    mode    => '0600',
    content => epp( 'puppetserver/database.ini.epp',
                    { 'user' => $user,
                      'db'   => $db,
                      'pwd'  => $pwd,
                    },
                  ),
    before => Service['puppetdb'],
    notify => Service['puppetdb'],
  }

  file { '/etc/puppetlabs/puppetdb/conf.d/jetty.ini':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp( 'puppetserver/jetty.ini.epp',
                    { 'puppetdb_ssl_dir' => $puppetdb_ssl_dir,
                    },
                  ),
    before => Service['puppetdb'],
    notify => Service['puppetdb'],
  }

  file { [
           "${puppetdb_ssl_dir}/ca.pem",
           "${puppetdb_ssl_dir}/public.pem",
           "${puppetdb_ssl_dir}/private.pem",
           "${puppetdb_ssl_dir}/crl.pem",
         ]:
    ensure => present,
    owner  => 'puppetdb',
    group  => 'puppetdb',
    mode   => '0600',
    before => Service['puppetdb'],
    notify => Service['puppetdb'],
  }

  # Note
  #
  # It was possible to do something like that:
  #
  #    file { "${puppetdb_ssl_dir}/private.pem" :
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
  #      source => "${puppet_ssl_dir}/private_keys/${::fqdn}.pem",
  #
  #    }
  #
  # But in this case, the content of the file appears in the
  # working directory of puppet (in /var/lib/puppet/) which it
  # bothers me a little. So I prefer some "exec" resources.

  exec { 'puppetdb-update-private.pem':
    command => "cat '${puppet_ssl_dir}/private_keys/${::fqdn}.pem' >'${puppetdb_ssl_dir}/private.pem'",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "diff -q '${puppet_ssl_dir}/private_keys/${::fqdn}.pem' '${puppetdb_ssl_dir}/private.pem'",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  exec { 'puppetdb-update-ca.pem':
    command => "cat '${puppet_ssl_dir}/certs/ca.pem' >'${puppetdb_ssl_dir}/ca.pem'",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "diff -q '${puppet_ssl_dir}/certs/ca.pem' '${puppetdb_ssl_dir}/ca.pem'",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  exec { 'puppetdb-update-public.pem':
    command => "cat '${puppet_ssl_dir}/certs/${::fqdn}.pem' >'${puppetdb_ssl_dir}/public.pem'",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "diff -q '${puppet_ssl_dir}/certs/${::fqdn}.pem' '${puppetdb_ssl_dir}/public.pem'",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  exec { 'puppetdb-update-crl.pem':
    command => "cat '${puppet_ssl_dir}/crl.pem' >'${puppetdb_ssl_dir}/crl.pem'",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "diff -q '${puppet_ssl_dir}/crl.pem' '${puppetdb_ssl_dir}/crl.pem'",
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
    enable     => true,
  }

}



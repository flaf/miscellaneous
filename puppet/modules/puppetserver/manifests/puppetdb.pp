class puppetserver::puppetdb {

  ensure_packages(['puppetdb'], { ensure => present, })

  $db               = $::puppetserver::puppetdb_name
  $user             = $::puppetserver::puppetdb_user
  $pwd              = $::puppetserver::puppetdb_pwd
  $memory           = $::puppetserver::puppetdb_memory
  $certwhitelist    = $::puppetserver::puppetdb_certwhitelist

  $puppet_ssl_dir     = $::puppetserver::ssldir
  $puppetlabs_path    = $::puppetserver::puppetlabs_path
  $puppetdb_path      = "${puppetlabs_path}/puppetdb"
  $puppetdb_ssl_dir   = "${puppetdb_path}/ssl"
  $certwhitelist_file = "${puppetdb_path}/certificate-whitelist"

  case $certwhitelist.empty {

    true: {
      $ensure_puppetdb_ini  = 'absent'
      $ensure_certwhitelist = 'absent'
    }

    default: {
      $ensure_puppetdb_ini  = 'present'
      $ensure_certwhitelist = 'present'
    }

  }

  # Set the memory for the JVM which runs the puppetdb.
  $java_args = "-Xmx${memory}"

  file_line { 'set-memory-to-puppetdb-jvm':
    path   => '/etc/default/puppetdb',
    line   => "JAVA_ARGS=\"${java_args}\" # line edited by Puppet.",
    match  => '^JAVA_ARGS=.*$',
    before => Service['puppetdb'],
    notify => Service['puppetdb'],
  }

  # This file tell to the puppetdb web server how to
  # contact the database.
  file { "${puppetdb_path}/conf.d/database.ini":
    ensure  => present,
    owner   => 'puppetdb',
    group   => 'puppetdb',
    mode    => '0600',
    content => epp( 'puppetserver/database.ini.epp',
                    {
                      'user' => $user,
                      'db'   => $db,
                      'pwd'  => $pwd,
                    },
                  ),
    before => Service['puppetdb'],
    notify => Service['puppetdb'],
  }

  file { "${puppetdb_path}/conf.d/puppetdb.ini":
    ensure  => $ensure_puppetdb_ini,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp( 'puppetserver/puppetdb.ini.epp',
                    {
                      'certwhitelist_file' => $certwhitelist_file,
                    },
                  ),
    before => Service['puppetdb'],
    notify => Service['puppetdb'],
  }

  file { $certwhitelist_file:
    ensure  => $ensure_certwhitelist,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp( 'puppetserver/certificate-whitelist.epp',
                    {
                      'certwhitelist' => $certwhitelist,
                    },
                  ),
    before => Service['puppetdb'],
    notify => Service['puppetdb'],
  }

  file { "${puppetdb_path}/conf.d/jetty.ini":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp( 'puppetserver/jetty.ini.epp',
                    { 'puppetdb_ssl_dir' => $puppetdb_ssl_dir, },
                  ),
    before => Service['puppetdb'],
    notify => Service['puppetdb'],
  }

  file { $puppetdb_ssl_dir:
    ensure => directory,
    owner  => 'puppetdb',
    group  => 'puppetdb',
    mode   => '0600',
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
  # working directory of puppe which it bothers me a little.
  # So I choose some inelegant "exec" resources.

  $privpem = "${puppet_ssl_dir}/private_keys/${::fqdn}.pem"
  $pubpem  = "${puppet_ssl_dir}/certs/${::fqdn}.pem"
  $capem   = "${puppet_ssl_dir}/certs/ca.pem"
  $crlpem  = "${puppet_ssl_dir}/ca/ca_crl.pem"

  exec { 'puppetdb-update-private.pem':
    command => "cat '${privpem}' >'${puppetdb_ssl_dir}/private.pem'",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "diff -q '${privpem}' '${puppetdb_ssl_dir}/private.pem'",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  exec { 'puppetdb-update-public.pem':
    command => "cat '${pubpem}' >'${puppetdb_ssl_dir}/public.pem'",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "diff -q '${pubpem}' '${puppetdb_ssl_dir}/public.pem'",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  exec { 'puppetdb-update-ca.pem':
    command => "cat '${capem}' >'${puppetdb_ssl_dir}/ca.pem'",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "diff -q '${capem}' '${puppetdb_ssl_dir}/ca.pem'",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  # Very important to update the CRL file of the puppetdb
  # via the CRL of the Puppet CA.
  exec { 'puppetdb-update-crl.pem':
    command => "cat '${crlpem}' >'${puppetdb_ssl_dir}/crl.pem'",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "diff -q '${crlpem}' '${puppetdb_ssl_dir}/crl.pem'",
    before  => Service['puppetdb'],
    notify  => Service['puppetdb'],
  }

  # TESTED: puppetdb (jetty in fact) have the ssl-crl-path
  # parameter in jetty.ini. When the CRL of the puppet CA
  # is updated (for instance after a `puppet node clean $host`,
  # the CRL of puppetdb is really updated too and puppetdb is
  # restarted. After that, a certificate in the CRL of puppetdb
  # is really disable when we want to contact the puppetdb.

  service { 'puppetdb':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }

}



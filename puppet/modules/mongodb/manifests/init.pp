class mongodb (
  Array[String[1], 1] $supported_distributions,
) {

  if !defined(Class['::mongodb::params']) { include '::mongodb::params' }
  $bind_ip    = $::mongodb::params::bind_ip
  $port       = $::mongodb::params::port
  $auth       = $::mongodb::params::auth
  $replset    = $::mongodb::params::replset
  $smallfiles = $::mongodb::params::smallfiles
  $keyfile    = $::mongodb::params::keyfile
  $quiet      = $::mongodb::params::quiet
  $log_level  = $::mongodb::params::log_level
  $logpath    = $::mongodb::params::logpath
  $databases  = $::mongodb::params::databases

  $has_keyfile = $keyfile ? {
    ''      => false,
    default => true,
  }

  $ensure_keyfile = $keyfile ? {
    ''      => 'absent',
    default => 'present',
  }

  ensure_packages( [ 'mongodb-server',
                     'mongodb-clients' ], { ensure => present } )

  file { '/etc/mongodb.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    require => [ Package['mongodb-server'], Package['mongodb-clients'] ],
    notify  => Service['mongodb'],
    content => epp('mongodb/mongodb.conf.epp',
                   {
                    'bind_ip'     => $bind_ip,
                    'port'        => $port,
                    'auth'        => $auth,
                    'replset'     => $replset,
                    'smallfiles'  => $smallfiles,
                    'has_keyfile' => $has_keyfile,
                    'quiet'       => $quiet,
                    'log_level'   => $log_level,
                    'logpath'     => $logpath,
                   }
                  )
  }

  file { '/etc/mongodb.keyfile':
    ensure  => $ensure_keyfile,
    owner   => 'mongodb',
    group   => 'root',
    mode    => '0400',
    require => [ Package['mongodb-server'], Package['mongodb-clients'] ],
    notify  => Service['mongodb'],
    content => $keyfile,
  }

  # On Trusty, mongod has a "status" command but the exit
  # code is 0 even if service is not running. The custom
  # command uses pgrep in the "procps" package.
  ensure_packages( [ 'procps' ], { ensure => present } )
  service { 'mongodb':
    ensure     => running,
    hasstatus  => false,
    status     => 'test "$(pgrep -c mongod)" != 0',
    hasrestart => true,
    enable     => true,
    require    => [ File['/etc/mongodb.conf'], File['/etc/mongodb.keyfile'] ],
  }

  file { '/root/create-dbs-users.js':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => epp('mongodb/create-dbs-users.js.epp', { 'databases' => $databases })
  }

  file { '/root/.mongorc.js':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => epp('mongodb/mongorc.js.epp', { 'databases' => $databases })
  }

}



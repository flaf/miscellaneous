class mongodb (
  Array[String[1], 1] $supported_distributions,
) {

  include '::mongodb::params'
  $bind_ip    = $::mongodb::params::bind_ip
  $port       = $::mongodb::params::port
  $noauth     = $::mongodb::params::noauth
  $replset    = $::mongodb::params::replset
  $smallfiles = $::mongodb::params::smallfiles
  $databases  = $::mongodb::params::databases

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
                    'bind_ip'    => $bind_ip,
                    'port'       => $port,
                    'noauth'     => $noauth,
                    'replset'    => $replset,
                    'smallfiles' => $smallfiles,
                   }
                  )
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
    require    => File['/etc/mongodb.conf'],
  }

  file { '/root/create-dbs-users.js':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0400',
    content => epp('mongodb/create-dbs-users.js.epp', { 'databases' => $databases })
  }

}



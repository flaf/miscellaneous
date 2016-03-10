class snmp (
  Array[String[1], 1] $supported_distributions,
) {

  if !defined(Class['::snmp::params']) { include '::snmp::params' }
  $interface       = $::snmp::params::interface
  $port            = $::snmp::params::port
  $syslocation     = $::snmp::params::syslocation
  $syscontact      = $::snmp::params::syscontact
  $snmpv3_accounts = $::snmp::params::snmpv3_accounts
  $communities     = $::snmp::params::communities
  $views           = $::snmp::params::views

  # Check the structure of the snmv3 accounts.
  $snmpv3_accounts.each |$account, $properties| {
    [ 'name', 'authpass', 'privpass' ].each |$key| {
      unless $key in $properties {
        regsubst(@("END"), '\n', ' ', 'G').fail
          $title: sorry, problem with the snmpv3 account `$account`.
          The key `$key` is mandatory and currently not present.
          |- END
      }
    }
  }

  # Check the structure of the communities.
  $communities.each |$community, $properties| {
    [ 'name', 'access' ].each |$key| {
      unless $key in $properties {
        regsubst(@("END"), '\n', ' ', 'G').fail
          $title: sorry, problem with the snmp community `$community`.
          The key `$key` is mandatory and currently not present.
          |- END
      }
    }
    unless $properties['name'] =~ String[1] {
      regsubst(@("END"), '\n', ' ', 'G').fail
        $title: sorry, problem with the snmp community `$community`.
        The key `name` must be a non empty string and this is not the
        case currently.
        |- END
    }
    $access = $properties['access']
    $msg    = @("END")
      $title: sorry, problem with the snmp community `$community`.
      The key `access` must be a non empty array of hashes with the
      keys `source` (mandatory) and `view` (optional) and strings
      as value. This is not the case currently.
      |- END
    unless $access =~ Array[ Hash[String[1], String[1], 1, 2], 1 ] {
      regsubst($msg, '\n', ' ', 'G').fail
    }
    $access.each |$an_access| {
      if ! $an_access.has_key('source') { regsubst($msg, '\n', ' ', 'G').fail }
    }
  }

  require '::repository::shinken'

  # In fact, snmpd is useless here, because it's a dependency
  # of the the package snmpd-extend.
  ensure_packages( [ 'snmpd', 'snmpd-extend' ], { ensure => present } )

  file { '/etc/snmp/snmpd.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Package['snmpd'],
    notify  => Service['snmpd'],
    content => epp('snmp/snmpd.conf.epp',
                   {
                    'interface'       => $interface,
                    'port'            => $port,
                    'syslocation'     => $syslocation,
                    'syscontact'      => $syscontact,
                    'snmpv3_accounts' => $snmpv3_accounts,
                    'communities'     => $communities,
                    'views'           => $views,
                   }
                  ),
  }

  service { 'snmpd':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
    require    => File['/etc/snmp/snmpd.conf'],
  }

}



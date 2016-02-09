class snmp (
  Array[String[1], 1] $supported_distributions,
) {

  require '::repository::shinken'

  include '::snmp::params'
  $interface       = $::snmp::params::interface
  $port            = $::snmp::params::port
  $syslocation     = $::snmp::params::syslocation
  $syscontact      = $::snmp::params::syscontact
  $snmpv3_accounts = $::snmp::params::snmpv3_accounts
  $communities     = $::snmp::params::communities
  $views           = $::snmp::params::views

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


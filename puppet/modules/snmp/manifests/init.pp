class snmp {

  include '::snmp::params'

  [
    $interface,
    $port,
    $syslocation,
    $syscontact,
    $snmpv3_accounts,
    $communities,
    $views,
    $supported_distributions,
  ] = Class['::snmp::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ensure_packages( [ 'snmpd' ], { ensure => present } )

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



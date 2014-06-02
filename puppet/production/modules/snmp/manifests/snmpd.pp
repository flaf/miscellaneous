#==Action
#
# Install and configure the snmpd daemon.
# Tested with Debian Lenny, Debian Squeeze and Debian Wheezy.
#
# This class depends on:
# - generate_password function to avoid to put clear text passwords in hiera.
#   You can can use clear text passwords or use the __pwd__ syntax in hiera.
#
#
#==Hiera
#
#  snmp:
#
#    # Definition of views.
#    views:
#      monitoring:
#        - '.1.3.6.1.2.1'
#        - '.1.3.6.1.4.1'
#
#    # The SNMPv3 configuration (authentification and view).
#    secname: '__pwd__{"salt" => ["$datacenter", "snmp-secname"], "nice" => true, "max_length" => 12}'
#    authpass: '__pwd__{"salt" => ["$datacenter", "snmp-authpass"]}'
#    authproto: 'sha'
#    privpass: '__pwd__{"salt" => ["$datacenter", "snmp-privpass"], "nice" => true, "case" => "upper"}'
#    privproto: 'aes'
#    secview: 'monitoring'
#
#    # The community password for SNMPv2c.
#    community: 'communtypass'
#
#    # Addresses allowed to do SNMPv2c requests and the corresponding view.
#    sources:
#      'localhost': 'monitoring'
#      '192.168.0.4': 'monitoring'
#      '192.168.0.5': 'monitoring'
#
#
class snmp::snmpd {

  require snmp::params

  $secname   = $snmp::params::secname
  $authpass  = $snmp::params::authpass
  $authproto = $snmp::params::authproto
  $privpass  = $snmp::params::privpass
  $privproto = $snmp::params::privproto
  $community = $snmp::params::community
  $secview   = $snmp::params::secview
  $views     = $snmp::params::views
  $sources   = $snmp::params::sources

  case $lsbdistcodename {
    'lenny': {
      $snmpd_hasstatus       = false
      $snmpd_default_variant = 'lenny'
    }
    'squeeze': {
      # Don't use hasstatus on squeeze because it also checks the snmptrapd which
      # is not always active
      $snmpd_hasstatus       = false
      $snmpd_default_variant = 'default'
    }
    default: {
      $snmpd_hasstatus       = true
      $snmpd_default_variant = 'default'
    }
  }

  package { 'snmpd':
    ensure => latest,
  }

  file { '/etc/snmp/snmpd.conf':
    content => template('snmp/snmpd.conf.erb'),
    owner   => root,
    group   => root,
    mode    => 0600,
    notify  => Service['snmpd'],
    require => Package['snmpd'],
  }

  file { '/etc/default/snmpd':
    content => template("snmp/snmpd.default.${snmpd_default_variant}.erb"),
    owner   => root,
    group   => root,
    mode    => 0644,
    notify  => Service['snmpd'],
    require => Package['snmpd'],
  }

  service { 'snmpd':
    ensure     => running,
    hasstatus  => $snmpd_hasstatus,
    require    => Package['snmpd'],
  }

}




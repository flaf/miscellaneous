# Public class to manage the NTP service.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib.
#
# == Parameters
#
# *interfaces:*
# An array of interfaces names used by the NTP service.
# The default value is [] (empty array) which means all
# interfaces are used.
#
# *subnets_authorized:*
# An array of CIDR addresses of only subnets authorized
# to exchange time with the NTP service. If this array
# contains the string 'all', then any host for any subnet
# can exchange time with the NTP service.
# The default value of this parameter is [] (empty array)
# ie no host can exchange time with the NTP service (ie
# a selfish NTP server).
#
# *ipv6:*
# A boolean. If true, IPv6 is taken into account in the
# /etc/ntp.conf file. If false, just IPv4 stanza are used
# in this file. The default value is true.
#
# *ntp_servers:*
# An array of ntp servers addresses. This parameter is
# mandatory and has no default value.
#
# == Sample Usages
#
#  class { '::ntp'
#    interfaces         => [ 'eth0' ],
#    subnets_authorized => [ '172.31.0.0/16', ],
#    ipv6               => false,
#    ntp_servers        => [ '172.31.5.1', '172.31.5.2', '172.31.5.3', ]
#  }
#
# or more simple (a basic and selfish NTP server) :
#
#  class { '::ntp'
#    ntp_servers => [ '172.31.5.1', '172.31.5.2', '172.31.5.3', ]
#  }
#
class ntp (
  $interfaces         = [],
  $subnets_authorized = [],
  $ipv6               = true,
  $ntp_servers,
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  # Check parameters.
  validate_array($interfaces)
  validate_array($subnets_authorized)
  validate_bool($ipv6)
  validate_array($ntp_servers)
  if empty($ntp_servers) {
    fail("In the ${tilte} class, `ntp_servers` parameter must not be empty.")
  }

  # Useful variables for the template.
  if empty($interfaces) {
    $all_interfaces = true
  } else {
    $all_interfaces = false
  }

  if member($subnets_authorized, 'all') {
    $selfish = false
  } else {
    $selfish = true
  }




  if ! defined(Package['ntp']) {
    package { 'ntp':
      ensure => present,
    }
  }

  file { '/etc/ntp.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ntp/ntp.conf.erb'),
    require => Package['ntp'],
    notify  => Service['ntp'],
  }

  $adjust      = 'ntpd -gq; sleep 0.5'
  $start_cmd   = "${adjust}; ${adjust}; service ntp start"
  $restart_cmd = "service ntp stop; ${adjust}; ${adjust}; service ntp start"
  service { 'ntp':
    ensure    => running,
    hasstatus => true,
    restart   => $restart_cmd,
    start     => $start_cmd,
    require   => File['/etc/ntp.conf'],
  }

}



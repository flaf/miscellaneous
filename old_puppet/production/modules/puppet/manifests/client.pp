# Very basic Puppet class to manage the
# /etc/puppet/puppet.conf file for a Puppet client.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib.
#
# == Parameters
#
# *service_enable:*
# A boolean parameter. If true, the service puppet agent will
# be enabled (ie at each boot of the OS, it will start). If
# false, the service puppet agent will be disabled (ie at each
# boot of the OS, it won't start). The default value is false.
#
# *runinterval:*
# A string which tells how often puppet agent applies the catalog.
# The default value is '30m' (ie 30 minutes). Of we don't care
# about this parameter if the service is disabled.
#
# *pluginsync:*
# A boolean parameter which tells whether plugins should be
# synced with the central server. It's recommended to set
# this parameter to true. The default value is true.
#
# *server*:
# The address of the puppetmaster. The default value is
# undef, ie the puppet agent will try to reach the server
# called "puppet" (the default value of the "server"
# parameter in /etc/puppet.conf).
#
# == Sample Usages
#
#  include '::puppet::client'
#
# or:
#
#  class { '::puppet::client':
#    service_enable => true,
#    runinterval    => '60s', # 60 seconds!
#  }
#
class puppet::client (
  $service_enable = false,
  $runinterval    = '30m',
  $pluginsync     = true,
  $server         = undef,
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  validate_bool($service_enable, $pluginsync)
  validate_string($runinterval)

  ensure_packages(['puppet', ], { ensure => present, })

  # Command to test if we should disable or enable the service.
  $test_cmd = "ls /etc/rc?.d | grep -qE 'S[0-9]{,2}puppet'"

  if $service_enable {
    $ensure_value = 'running'
    $cmd          = 'update-rc.d puppet enable'
    $unless       = $test_cmd
    $onlyif       = undef
    $start        = 'yes'
    $notify       = Service['puppet']
  } else {
    $ensure_value = 'stopped'
    $cmd          = 'update-rc.d puppet disable'
    $unless       = undef
    $onlyif       = $test_cmd
    $start        = 'no'
    $notify       = undef # Do not refresh the service in this case.
  }

  file { '/etc/puppet/puppet.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet/puppet.conf.client.erb'),
    require => Package['puppet'],
    before  => Service['puppet'],
    notify  => $notify,
  }

  # Disable of enable the service.
  exec { 'manage-service-puppet-agent':
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    command => $cmd,
    user    => 'root',
    group   => 'root',
    unless  => $unless,
    onlyif  => $onlyif,
    require => Package['puppet'],
    before  => Service['puppet'],
  }

  if $::lsbdistcodename == 'wheezy' {
    file { '/etc/default/puppet':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0644',
      content => template('puppet/puppet.default.client.erb'),
      require => Package['puppet'],
      before  => Service['puppet'],
      notify  => $notify,
    }
  }

  service { 'puppet':
    ensure     => $ensure_value,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['puppet'],
  }

}



# Very basic Puppet class to manage the /etc/puppet/puppet.conf file
# for a Puppet client.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib.
#
# == Parameters
#
# No parameter.
#
# == Sample Usages
#
#  include '::puppet::client'
#
class puppet::client (
  $service_enable = false,
  $runinterval    = '30m',
  $pluginsync     = true,
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

  file { '/etc/puppet/puppet.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppet/puppet.conf.client.erb'),
    require => Package['puppet'],
    before  => Service['puppet'],
  }

  # Command to test if we should disable or enable the service.
  $test_cmd = "ls /etc/rc?.d | grep -qE 'S[0-9]{,2}puppet'"

  if $service_enable {
    $ensure_value = 'running'
    $cmd          = 'update-rc.d puppet enable'
    $unless       = $test_cmd
    $onlyif       = undef
    $start        = 'yes'
  } else {
    $ensure_value = 'stopped'
    $cmd          = 'update-rc.d puppet disable'
    $unless       = undef
    $onlyif       = $test_cmd
    $start        = 'no'
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
    }
  }

  service { 'puppet':
    ensure     => $ensure_value,
    hasrestart => true,
    hasstatus  => true,
    require    => Package['puppet'],
  }

}



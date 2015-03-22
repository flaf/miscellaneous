# == Class: puppetmaster
#
# Module to deploy a puppetmaster.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { 'puppetmaster':
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# François Lafont <francois.lafont@ac-versailles.fr>
#
# === Copyright
#
# Copyright 2015 François Lafont
#
class puppetmaster (
  $server               = $::puppetmaster::params::server,
  $module_repository    = $::puppetmaster::params::module_repository,
  $environment_timeout  = $::puppetmaster::params::environment_timeout,
  $puppetdb             = $::puppetmaster::params::puppetdb,
  $puppetdb_user        = $::puppetmaster::params::puppetdb_user,
  $puppetdb_pwd         = $::puppetmaster::params::puppetdb_pwd,
  $admin_email          = $::puppetmaster::params::admin_email,
  $hiera_git_repository = $::puppetmaster::params::hiera_git_repository,
) inherits ::puppetmaster::params {

  case $::lsbdistcodename {
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  $environment_path = '/puppet'

  require '::puppetmaster::packages'
  require '::puppetmaster::postgresql'
  require '::puppetmaster::puppetdb'
  require '::puppetmaster::puppet_config'
  require '::puppetmaster::git_ssh'

  Class['::puppetmaster::packages']
    -> Class['::puppetmaster::postgresql']
    -> Class['::puppetmaster::puppetdb']
    -> Class['::puppetmaster::puppet_config']
    -> Class['::puppetmaster::git_ssh']

}



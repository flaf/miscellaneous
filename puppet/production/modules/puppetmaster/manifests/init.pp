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
  $puppet_server        = $::puppetmaster::params::puppet_server,
  $ca_server            = $::puppetmaster::params::ca_server,
  $module_repository    = $::puppetmaster::params::module_repository,
  $environment_timeout  = $::puppetmaster::params::environment_timeout,
  $puppetdb_server      = $::puppetmaster::params::puppetdb_server,
  $puppetdb_dbname      = $::puppetmaster::params::puppetdb_dbname,
  $puppetdb_user        = $::puppetmaster::params::puppetdb_user,
  $puppetdb_pwd         = $::puppetmaster::params::puppetdb_pwd,
  $generate_eyaml_keys  = $::puppetmaster::params::generate_eyaml_keys,
  $extdata              = $::puppetmaster::params::extdata,
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

  # 1. Installation of packages.
  class { '::puppetmaster::packages':
    before => Class['::puppetmaster::puppet_config'],
  }

  # 2. Of course, the configuration of puppet is mandatory.
  # The configuration of puppet comes before the
  # configuration of puppetdb because puppetdb uses
  # certificates, CRL etc. of puppet. So it's better to have
  # puppet configured before puppetdb.
  class { '::puppetmaster::puppet_config': }

  # 3. If the server provides the puppetdb service...
  if $puppetdb_server == '<myself>' {

    class { '::puppetmaster::postgresql':
      require => Class['::puppetmaster::puppet_config'],
    }

    class { '::puppetmaster::puppetdb':
      require => Class['::puppetmaster::postgresql'],
      before  => Class['::puppetmaster::git_ssh'],
    }

  }

  # 4. If there is a git reporitory dedicated to the server...
  if $hiera_git_repository != '<none>' {

    class { '::puppetmaster::git_ssh':
      require => Class['::puppetmaster::puppet_config'],
    }

  }

  # 5. Alert for cleaning if the server is CA and is the puppet
  # client of itself.

  # TODO: only when the "refreshonly" attribute will be
  # accepted in a "notify" resource:
  #
  #   https://tickets.puppetlabs.com/browse/PUP-4213
  #

#  if $ca_server == '<myself>' and $puppet_server == '<myself>' {
#
#    exec { 'puppetdb-update-private.pem':
#      command => 'true',
#      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
#      user    => 'root',
#      group   => 'root',
#      onlyif  => 'test -d /var/lib/puppet/sslclient',
#      before  => Notify['alert-remove-sslclient'],
#      notify  => Notify['alert-remove-sslclient'],
#    }
#
#    $msg_ssl = "
#
#The directory /var/lib/puppet/sslclient is useless now.
#Henceforth, the current host is Puppet CA and is the puppet
#client of itself. You should remove this directory and revoke
#the certificate used in this directory.
#
#"
#
#    notify { 'alert-remove-sslclient':
#      message     => $msg_ssl,
#      refreshonly => true,
#    }
#
#  }

}



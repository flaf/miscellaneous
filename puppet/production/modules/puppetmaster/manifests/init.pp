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

  # 2. If the server provides the puppetdb service...
  if $puppetdb_server == '<myself>' {

    class { '::puppetmaster::postgresql':
      require => Class['::puppetmaster::packages'],
    }

    class { '::puppetmaster::puppetdb':
      require => Class['::puppetmaster::postgresql'],
      before  => Class['::puppetmaster::puppet_config'],
    }

  }

  # 3. Of course, the configuration of puppet is mandatory.
  class { '::puppetmaster::puppet_config': }

  # 4. If there is a git reporitory dedicated to the server...
  if $hiera_git_repository != '<none>' {

    class { '::puppetmaster::git_ssh':
      require => Class['::puppetmaster::puppet_config'],
    }

  }

  # 5. Alert for cleaning if the server is CA and is the puppet
  # client of itself.
  if $ca_server == '<myself>' and $puppet_server == '<myself>' {

    $msg_ssl = "\n\nThe directory /var/lib/puppet/sslclient is useless now.\n\
Henceforth, the current host is Puppet CA and is the puppet client of itself.\n\
You should remove this directory and revoke the certificate used for this\n\
puppet run (normally the CA of this certificate is ${::servername}).\n\n"

    notify { 'alert-remove-sslclient':
      message => $msg_ssl,
    }

  }

}



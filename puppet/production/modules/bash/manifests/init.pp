# Very basic Puppet class to ensure the installation of
# bash and bash-completion packages. This class manages
# too a basic /root/.bashrc.puppet sourced by bash.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib
#
# == Parameters
#
# No parameter.
#
# == Sample Usages
#
#  include '::bash'
#
class bash {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  ensure_packages(['bash', 'bash-completion', ], { ensure => present, })

  file_line { 'edit-bashrc-of-root':
    path => '/root/.bashrc',
    line => '. /root/.bashrc.puppet # Edited by Puppet.',
  }

  file { '/root/.bashrc.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('bash/bashrc.puppet.erb'),
  }

}



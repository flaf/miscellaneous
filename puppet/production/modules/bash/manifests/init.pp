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
# *root_prompt_color:*
# A string to choose the main color of the root's prompt
# with bash. See the code to know the authorized colors.
# The default value of this parameter is 'red'.
#
# == Sample Usages
#
#  include '::bash'
#
class bash (
  $root_prompt_color = 'red',
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  $colors = {
           # color    => number in bash (see the templates)
             'red'    => '31',
             'green'  => '32',
             'yellow' => '33',
             'blue'   => '34',
             'purple' => '35',
             'cyan'   => '36',
             'white'  => '37',
            }

  validate_string($root_prompt_color)
  $colors_array = keys($colors)
  unless member($colors_array, $root_prompt_color) {
    fail("Class ${title}, value of the `root_prompt_color` parameter \
unsupported (value `${root_prompt_color}` unsupported).")
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



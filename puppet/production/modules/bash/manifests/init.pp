# Puppet class to ensure the installation of bash and
# bash-completion packages. This class manages the
# ~/.bashrc.puppet file sourced by bash.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib
#
# == Parameters
#
# *user*:
# The user account whose file ~/.bashrc.puppet will be managed.
# This parameter is optional and the default value is the title
# of the current resource.
#
# *home*:
# The home directory of the user. This parameter is optional.
# The default value will be /root if the user is root otherwise
# it will be /home/${user}.
#
# *prompt_color*:
# A string to choose the main color of the user's prompt
# with bash. See the code to know the authorized colors.
# The default value of this parameter is 'red'.
#
# *content*:
# An array of lines in the ~/.bashrc.puppet file.
# This parameter is optional. See the code below to
# know the default value.
#
# == Sample Usages
#
#  ::bash::bashrc {'joe'
#    prompt_color => 'purple',
#    content      => [
#                     "alias ll='\ls --color -lap'",
#                    ],
#  }
#
define bash::bashrc (
  $user         = $title,
  $home         = undef,
  $prompt_color = 'red',
  $content      = [
                   "export EDITOR='vim'",
                    "alias vim='vim -p'",
                    "alias ll='\ls --color -lap'",
                    "alias grep='grep --color'",
                    "alias upgrade='apt-get update && apt-get upgrade'",
                    "alias poweroff='poweroff && exit'",
                    "alias reboot='reboot && exit'",
                    "alias rp='puppet agent --test'",
                    "alias crp='clear && puppet agent --test'",
                    "HISTSIZE='1000'",
                    "HISTFILESIZE='2000'",
                    "HISTCONTROL='ignoredups:ignorespace'",
                  ]
) {

  $colors = {
    # color  => number in bash (see the templates)
    'red'    => '31',
    'green'  => '32',
    'yellow' => '33',
    'blue'   => '34',
    'purple' => '35',
    'cyan'   => '36',
    'white'  => '37',
  }

  validate_string($prompt_color)
  $colors_array = keys($colors)
  unless member($colors_array, $prompt_color) {
    fail("Class ${title}, value of the `prompt_color` parameter \
unsupported (value `${prompt_color}` unsupported).")
  }

  ensure_packages(['bash', 'bash-completion', ], { ensure => present, })

  if $home == undef {
    if $user  == 'root' {
      $home2  = '/root'
    } else {
      $home2  = "/home/${user}"
    }
  } else {
    $home2 = $home
  }

  if $user  == 'root' {
    $prompt = '#'
  } else {
    $prompt = '$'
  }

  file_line { "edit-bashrc-of-${user}":
    path => "${home2}/.bashrc",
    line => ". ${home2}/.bashrc.puppet # Edited by Puppet.",
  }

  file { "${home2}/.bashrc.puppet":
    ensure  => present,
    owner   => $user,
    group   => $user,
    mode    => '0644',
    content => template('bash/bashrc.puppet.erb'),
  }

}



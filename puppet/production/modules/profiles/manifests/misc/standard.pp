class profiles::misc::standard {

  $bash_conf         = hiera_hash('bash')
  $root_prompt_color = $bash_conf['root_prompt_color']

  if $root_prompt_color == undef {
    fail("Problem in class ${title}, `root_prompt_color` data not retrieved")
  }

  class { '::bash':
    root_prompt_color => $root_prompt_color,
  }

  include '::vim'

  # No mlocate installed on a puppet node.
  package { 'mlocate':
    ensure => purged,
  }

  $packages = [
                'gawk',
                'less',
                'lsb-release',
              ]

  ensure_packages($packages, { ensure => present, })

}



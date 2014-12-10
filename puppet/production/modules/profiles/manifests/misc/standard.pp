class profiles::misc::standard {

  include '::bash'
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



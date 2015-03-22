class profiles::misc::generic {

  # No mlocate installed on a puppet node.
  package { 'mlocate':
    ensure => purged,
  }

  $packages = [
                'gawk',
                'less',
                'lsb-release',
                'tree',        # /!\ For Ubuntu, tree is in "universe".
              ]

  ensure_packages($packages, { ensure => present, })

}



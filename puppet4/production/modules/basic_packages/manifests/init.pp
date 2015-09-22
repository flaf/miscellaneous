class basic_packages (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $packages = [ 'vim',
                'gawk',
                'less',
                'lsb-release',
                'tree',        # In Trusty, "tree" is in "universe".
              ]
  ensure_packages( $packages, { ensure => present } )

}



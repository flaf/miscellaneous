class basic_packages (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $packages = [ 'vim',
                'gawk',
                'bash-completion',
                'less',
                'lsb-release',
                'tree', # Warning, in Trusty, "tree" is in "universe".
                'tcpdump',
                'screen',
              ]
  ensure_packages( $packages, { ensure => present } )

}



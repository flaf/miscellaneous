class common {

  $common_packages = [ 'vim',
                       'lsb-release',
                       'less',
                       'tree',
                     ]

  package { [ $common_packages:
    ensure => latest,
  }

}



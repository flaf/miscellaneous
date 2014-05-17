class common {

  $common_packages = [ 'vim',
                       'lsb-release',
                       'less',
                       'tree',
                       'git',
                       'dnsutils',
                     ]

  package { $common_packages:
    ensure => latest,
  }

}



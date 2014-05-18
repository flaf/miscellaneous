class common {

  $common_packages = [ 'vim',
                       'lsb-release',
                       'less',
                       'tree',
                       'git',
                       'dnsutils',
                       'psmisc',
                     ]

  package { $common_packages:
    ensure => latest,
  }

}



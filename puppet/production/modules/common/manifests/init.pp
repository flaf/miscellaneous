class common {

  $common_packages = [ 'vim',
                       'lsb-release',
                       'less',
                       'tree',
                       'git',
                       'dnsutils',
                       'psmisc',
                       'gawk',
                     ]

  package { $common_packages:
    ensure => latest,
  }

}



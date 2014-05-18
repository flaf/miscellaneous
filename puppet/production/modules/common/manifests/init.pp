class common {

  $common_packages = [ 'vim',
                       'lsb-release',
                       'less',
                       'tree',
                       'git',
                       'dnsutils',
                       'psmisc',
                       'gawk',
                       'screen',
                       'tcpdump',
                     ]

  package { $common_packages:
    ensure => latest,
  }

}



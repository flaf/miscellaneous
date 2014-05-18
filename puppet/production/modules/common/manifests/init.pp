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
                       'rsync',
                     ]

  package { $common_packages:
    ensure => latest,
  }

}



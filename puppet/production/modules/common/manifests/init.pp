class common ($stage = 'base_packages')  {

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
                       'iftop',
                       'rsync',
                       'openssl',
                       'ca-certificates',
                       'curl',
                       'file',
                     ]

  package { 'common_packages':
    ensure => present,
    name   => $common_packages,
  }

}



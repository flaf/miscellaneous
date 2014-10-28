class basis ($stage = 'base_packages')  {

  if ! defined(Package['vim']) {
    package { 'vim':
      ensure => present,
    }
  }

  if ! defined(Package['lsb-release']) {
    package { 'lsb-release':
      ensure => present,
    }
  }

  if ! defined(Package['less']) {
    package { 'less':
      ensure => present,
    }
  }

  #if ! defined(Package['tree']) {
  #  package { 'tree':
  #    ensure => present,
  #  }
  #}

  if ! defined(Package['git']) {
    package { 'git':
      ensure => present,
    }
  }

  if ! defined(Package['dnsutils']) {
    package { 'dnsutils':
      ensure => present,
    }
  }

  if ! defined(Package['psmisc']) {
    package { 'psmisc':
      ensure => present,
    }
  }

  if ! defined(Package['gawk']) {
    package { 'gawk':
      ensure => present,
    }
  }

  if ! defined(Package['screen']) {
    package { 'screen':
      ensure => present,
    }
  }

  if ! defined(Package['tcpdump']) {
    package { 'tcpdump':
      ensure => present,
    }
  }

  #if ! defined(Package['iftop']) {
  #  package { 'iftop':
  #    ensure => present,
  #  }
  #}

  if ! defined(Package['rsync']) {
    package { 'rsync':
      ensure => present,
    }
  }

  if ! defined(Package['curl']) {
    package { 'curl':
      ensure => present,
    }
  }

  if ! defined(Package['file']) {
    package { 'file':
      ensure => present,
    }
  }

  if ! defined(Package['openssl']) {
    package { 'openssl':
      ensure => present,
    }
  }

  if ! defined(Package['ca-certificates']) {
    package { 'ca-certificates':
      ensure => present,
    }
  }

}



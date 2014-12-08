class profiles::misc::standard {

  include '::bash'
  include '::vim'

  # No mlocate installed on a puppet node.
  package { 'mlocate':
    ensure => purged,
  }

  if ! defined(Package['gawk']) {
    package { 'gawk':
      ensure => present,
    }
  }

  if ! defined(Package['less']) {
    package { 'less':
      ensure => present,
    }
  }

  if ! defined(Package['lsb-release']) {
    package { 'lsb-release':
      ensure => present,
    }
  }

}



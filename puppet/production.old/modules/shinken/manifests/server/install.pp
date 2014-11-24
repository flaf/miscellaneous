class shinken::server::install {

  # shinken-packs installs the shinken package
  # because of dependencies, but explicit is
  # better than implicit... ;-)
  package { ['shinken', 'shinken-packs', 'botirc-parrot']:
    ensure => present,
  }

  # If we use LDAPS for the authentifications, we need
  # these package.
  if ! defined(Package['openssl']) {
    package { 'openssl for shinken':
      name   => 'openssl',
      ensure => present,
    }
  }

  if ! defined(Package['ca-certificates']) {
    package { 'ca-certificates for shinken':
      name   => 'ca-certificates',
      ensure => present,
    }
  }

}



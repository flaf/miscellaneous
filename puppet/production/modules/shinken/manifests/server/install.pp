class shinken::server::install {

  # shinken-packs installs the shinken package
  # because of dependencies, but explicit is
  # better than implicit... ;-)
  package { ['shinken', 'shinken-packs', 'botirc-parrot']:
    ensure => present,
  }

  # If we use LDAPS for the authentifications, we need
  # these package.
  package { ['openssl', 'ca-certificates']:
    ensure => latest,
  }

}



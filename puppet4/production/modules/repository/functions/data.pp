function repository::data {

  case $::operatingsystem {

    'Debian': { $distrib_url = 'http://ftp.fr.debian.org/debian/' }
    'Ubuntu': { $distrib_url = 'http://fr.archive.ubuntu.com/ubuntu' }

  }

  # Pinning of the version of " puppet-agent" package
  # must be found in hiera or in the environment.
  $conf = lookup('puppet', Hash[String[1], String[1], 1], 'hash')

  if ! $conf.has_key('pinning_agent_version') {
    fail("The `puppet` entry must have a `pinning_agent_version` key.")
  }
  if ! $conf.has_key('collection') {
    fail("The `puppet` entry must have a `collection` key.")
  }

  $distribs = [ 'trusty', 'jessie' ]

  # Dedicated stage for this module.
  $stage = 'repository';

  {
    repository::distrib::url                     => $distrib_url,
    repository::distrib::src                     => false,
    repository::distrib::install_recommends      => false,
    repository::distrib::supported_distributions => $distribs,
    repository::distrib::stage                   => $stage,

    repository::puppet::url                     => 'http://apt.puppetlabs.com',
    repository::puppet::src                     => false,
    repository::puppet::collection              => $conf['collection'],
    repository::puppet::pinning_agent_version   => $conf['pinning_agent_version'],
    repository::puppet::supported_distributions => $distribs,
    repository::puppet::stage                   => $stage,

    repository::postgresql::url                     => 'http://apt.postgresql.org/pub/repos/apt/',
    repository::postgresql::src                     => false,
    repository::postgresql::supported_distributions => ['trusty'],
    repository::postgresql::stage                   => $stage,
  }

}



function repository::data {

  case $::operatingsystem {

    'Debian': {
      $distrib_url = 'http://ftp.fr.debian.org/debian/'
     }

    'Ubuntu': {
      $distrib_url = 'http://fr.archive.ubuntu.com/ubuntu'
     }

  }

  $repository_crdp_url                = 'http://repository.crdp.ac-versailles.fr/debian'
  $repositroy_crdp_gpgkey             = 'http://repository.crdp.ac-versailles.fr/crdp.gpg'
  $repositroy_crdp_gpgkey_fingerprint = '741FA112F3B2D515A88593F83DE39DE978BB3659';

  {

    repository::distrib::params::url                => $distrib_url,
    repository::distrib::params::src                => false,
    repository::distrib::params::install_recommends => false,
    repository::distrib::params::backports          => false,
    repository::distrib::supported_distributions    => [ 'trusty', 'jessie' ],

    repository::ceph::params::url             => 'http://ceph.com',
    repository::ceph::params::src             => false,
    repository::ceph::params::codename        => undef,
    repository::ceph::params::pinning_version => undef,
    repository::ceph::supported_distributions => [ 'trusty', 'jessie' ],

    repository::puppet::params::url                    => 'http://apt.puppetlabs.com',
    repository::puppet::params::src                    => false,
    repository::puppet::params::collection             => undef,
    repository::puppet::params::pinning_agent_version  => undef,
    repository::puppet::params::pinning_server_version => undef,
    repository::puppet::supported_distributions        => [ 'trusty', 'jessie' ],

    repository::postgresql::params::url             => 'http://apt.postgresql.org/pub/repos/apt/',
    repository::postgresql::params::src             => false,
    repository::postgresql::supported_distributions => [ 'trusty' ],

    repository::shinken::params::url             => $repository_crdp_url,
    repository::shinken::params::key_url         => $repositroy_crdp_gpgkey,
    repository::shinken::params::fingerprint     => $repositroy_crdp_gpgkey_fingerprint,
    repository::shinken::supported_distributions => [ 'trusty', 'jessie' ],

    repository::raid::params::url             => $repository_crdp_url,
    repository::raid::params::key_url         => $repositroy_crdp_gpgkey,
    repository::raid::params::fingerprint     => $repositroy_crdp_gpgkey_fingerprint,
    repository::raid::supported_distributions => [ 'trusty', 'jessie' ],

    repository::proxmox::params::url             => 'https://enterprise.proxmox.com/debian',
    repository::proxmox::supported_distributions => [ 'jessie' ],

    repository::hp_proliant::params::url             => 'http://downloads.linux.hpe.com/SDR/repo/mcp',
    repository::hp_proliant::supported_distributions => [ 'trusty', 'jessie' ],

    repository::moobot::params::url             => $repository_crdp_url,
    repository::moobot::params::key_url         => $repositroy_crdp_gpgkey,
    repository::moobot::params::fingerprint     => $repositroy_crdp_gpgkey_fingerprint,
    repository::moobot::supported_distributions => [ 'trusty', 'jessie' ],

    repository::mco::params::url             => $repository_crdp_url,
    repository::mco::params::key_url         => $repositroy_crdp_gpgkey,
    repository::mco::params::fingerprint     => $repositroy_crdp_gpgkey_fingerprint,
    repository::mco::supported_distributions => [ 'trusty', 'jessie' ],

    repository::jrds::params::url             => $repository_crdp_url,
    repository::jrds::params::key_url         => $repositroy_crdp_gpgkey,
    repository::jrds::params::fingerprint     => $repositroy_crdp_gpgkey_fingerprint,
    repository::jrds::supported_distributions => [ 'trusty', 'jessie' ],

    repository::php::params::url             => $repository_crdp_url,
    repository::php::params::key_url         => $repositroy_crdp_gpgkey,
    repository::php::params::fingerprint     => $repositroy_crdp_gpgkey_fingerprint,
    repository::php::supported_distributions => [ 'trusty', 'jessie' ],

    repository::docker::params::url             => 'http://apt.dockerproject.org/repo',
    repository::docker::params::src             => false,
    repository::docker::params::pinning_version => undef,
    repository::docker::supported_distributions => [ 'trusty', 'jessie' ],

  }

}



function repository::data {

  $distro_id = $::facts["os"]["distro"]["id"].downcase()

  case $distro_id {

    'debian': {
      $distrib_url = 'http://ftp.fr.debian.org/debian/'
     }

    'ubuntu': {
      $distrib_url = 'http://fr.archive.ubuntu.com/ubuntu'
     }

  }

  $repository_crdp_url                = 'http://repository.crdp.ac-versailles.fr/debian'
  $repositroy_crdp_gpgkey             = 'http://repository.crdp.ac-versailles.fr/crdp.gpg'
  $repositroy_crdp_gpgkey_fingerprint = '741FA112F3B2D515A88593F83DE39DE978BB3659'
  $sd                                 = 'supported_distributions';

  {

    repository::distrib::params::url                => $distrib_url,
    repository::distrib::params::src                => false,
    repository::distrib::params::install_recommends => false,
    repository::distrib::params::backports          => false,
   "repository::distrib::params::${sd}"             => [ 'trusty', 'jessie' ],

    repository::ceph::params::url             => 'http://download.ceph.com',
    repository::ceph::params::src             => false,
    repository::ceph::params::codename        => undef,
    repository::ceph::params::pinning_version => undef,
   "repository::ceph::params::${sd}"          => [ 'trusty', 'jessie' ],

    repository::puppet::params::url                    => 'http://apt.puppetlabs.com',
    repository::puppet::params::src                    => false,
    repository::puppet::params::collection             => undef,
    repository::puppet::params::pinning_agent_version  => undef,
    repository::puppet::params::pinning_server_version => undef,
   "repository::puppet::params::${sd}"                 => [ 'trusty', 'jessie' ],

    repository::postgresql::params::url    => 'http://apt.postgresql.org/pub/repos/apt/',
    repository::postgresql::params::src    => false,
   "repository::postgresql::params::${sd}" => [ 'trusty' ],

    repository::shinken::params::url         => $repository_crdp_url,
    repository::shinken::params::key_url     => $repositroy_crdp_gpgkey,
    repository::shinken::params::fingerprint => $repositroy_crdp_gpgkey_fingerprint,
   "repository::shinken::params::${sd}"      => [ 'trusty', 'jessie' ],

    repository::raid::params::url         => $repository_crdp_url,
    repository::raid::params::key_url     => $repositroy_crdp_gpgkey,
    repository::raid::params::fingerprint => $repositroy_crdp_gpgkey_fingerprint,
   "repository::raid::params::${sd}"      => [ 'trusty', 'jessie' ],

    repository::proxmox::params::url    => 'https://enterprise.proxmox.com/debian',
   "repository::proxmox::params::${sd}" => [ 'jessie' ],

    repository::hp_proliant::params::url    => 'http://downloads.linux.hpe.com/SDR/repo/mcp',
   "repository::hp_proliant::params::${sd}" => [ 'trusty', 'jessie' ],

    repository::moobot::params::url         => $repository_crdp_url,
    repository::moobot::params::key_url     => $repositroy_crdp_gpgkey,
    repository::moobot::params::fingerprint => $repositroy_crdp_gpgkey_fingerprint,
   "repository::moobot::params::${sd}"      => [ 'trusty', 'jessie' ],

    repository::mco::params::url         => $repository_crdp_url,
    repository::mco::params::key_url     => $repositroy_crdp_gpgkey,
    repository::mco::params::fingerprint => $repositroy_crdp_gpgkey_fingerprint,
   "repository::mco::params::${sd}"      => [ 'trusty', 'jessie' ],

    repository::jrds::params::url         => $repository_crdp_url,
    repository::jrds::params::key_url     => $repositroy_crdp_gpgkey,
    repository::jrds::params::fingerprint => $repositroy_crdp_gpgkey_fingerprint,
   "repository::jrds::params::${sd}"      => [ 'trusty', 'jessie' ],

    repository::php::params::url         => $repository_crdp_url,
    repository::php::params::key_url     => $repositroy_crdp_gpgkey,
    repository::php::params::fingerprint => $repositroy_crdp_gpgkey_fingerprint,
   "repository::php::params::${sd}"      => [ 'trusty', 'jessie' ],

    repository::docker::params::url             => 'http://apt.dockerproject.org/repo',
    repository::docker::params::src             => false,
    repository::docker::params::pinning_version => undef,
   "repository::docker::params::${sd}"          => [ 'trusty', 'jessie' ],

    repository::gitlab::params::url             => "http://packages.gitlab.com/gitlab/gitlab-ce/${distro_id}/",
    repository::gitlab::params::src             => false,
    repository::gitlab::params::pinning_version => undef,
   "repository::gitlab::params::${sd}"          => [ 'trusty' ],

  }

}



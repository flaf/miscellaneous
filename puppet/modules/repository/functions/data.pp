function repository::data {

  case $::operatingsystem {

    'Debian': { $distrib_url = 'http://ftp.fr.debian.org/debian/' }
    'Ubuntu': { $distrib_url = 'http://fr.archive.ubuntu.com/ubuntu' }

  }

  $repository_crdp_url                = 'http://repository.crdp.ac-versailles.fr/debian'
  $repositroy_crdp_gpgkey             = 'http://repository.crdp.ac-versailles.fr/crdp.gpg'
  $repositroy_crdp_gpgkey_fingerprint = '741FA112F3B2D515A88593F83DE39DE978BB3659'

  # Dedicated stage for this module.
  $stage = 'repository';

  {

    repository::params::distrib_url                   => $distrib_url,
    repository::params::distrib_src                   => false,
    repository::params::distrib_install_recommends    => false,
    repository::distrib::supported_distributions      => [ 'trusty', 'jessie' ],
    repository::distrib::stage                        => $stage,

    repository::params::ceph_url                      => 'http://ceph.com',
    repository::params::ceph_src                      => false,
    repository::params::ceph_codename                 => 'NOT-DEFINED',
    repository::params::ceph_pinning_version          => 'NOT-DEFINED',
    repository::ceph::supported_distributions         => [ 'trusty', 'jessie' ],
    repository::ceph::stage                           => $stage,

    repository::params::puppet_url                    => 'http://apt.puppetlabs.com',
    repository::params::puppet_src                    => false,
    repository::params::puppet_collection             => 'NOT-DEFINED',
    repository::params::puppet_pinning_agent_version  => 'NOT-DEFINED',
    repository::params::puppet_pinning_server_version => 'NOT-DEFINED',
    repository::puppet::supported_distributions       => [ 'trusty', 'jessie' ],
    repository::puppet::stage                         => $stage,

    repository::params::postgresql_url                => 'http://apt.postgresql.org/pub/repos/apt/',
    repository::params::postgresql_src                => false,
    repository::postgresql::supported_distributions   => [ 'trusty' ],
    repository::postgresql::stage                     => $stage,

    repository::params::shinken_url                   => $repository_crdp_url,
    repository::params::shinken_key_url               => $repositroy_crdp_gpgkey,
    repository::params::shinken_fingerprint           => $repositroy_crdp_gpgkey_fingerprint,
    repository::shinken::supported_distributions      => [ 'trusty', 'jessie' ],
    repository::shinken::stage                        => $stage,

    repository::params::raid_url                      => $repository_crdp_url,
    repository::params::raid_key_url                  => $repositroy_crdp_gpgkey,
    repository::params::raid_fingerprint              => $repositroy_crdp_gpgkey_fingerprint,
    repository::raid::supported_distributions         => [ 'trusty', 'jessie' ],
    repository::raid::stage                           => $stage,

    repository::params::proxmox_url                   => 'https://enterprise.proxmox.com/debian',
    repository::proxmox::supported_distributions      => [ 'jessie' ],
    repository::proxmox::stage                        => $stage,

    repository::params::moobot_url                    => $repository_crdp_url,
    repository::params::moobot_key_url                => $repositroy_crdp_gpgkey,
    repository::params::moobot_fingerprint            => $repositroy_crdp_gpgkey_fingerprint,
    repository::moobot::supported_distributions       => [ 'trusty', 'jessie' ],
    repository::moobot::stage                         => $stage,

    repository::params::mco_url                       => $repository_crdp_url,
    repository::params::mco_key_url                   => $repositroy_crdp_gpgkey,
    repository::params::mco_fingerprint               => $repositroy_crdp_gpgkey_fingerprint,
    repository::mco::supported_distributions          => [ 'trusty', 'jessie' ],
    repository::mco::stage                            => $stage,

    repository::params::jrds_url                      => $repository_crdp_url,
    repository::params::jrds_key_url                  => $repositroy_crdp_gpgkey,
    repository::params::jrds_fingerprint              => $repositroy_crdp_gpgkey_fingerprint,
    repository::jrds::supported_distributions         => [ 'trusty', 'jessie' ],
    repository::jrds::stage                           => $stage,

    repository::params::docker_url                    => 'http://apt.dockerproject.org/repo',
    repository::params::docker_src                    => false,
    repository::params::docker_pinning_version        => 'NOT-DEFINED',
    repository::docker::supported_distributions       => [ 'trusty', 'jessie' ],
    repository::docker::stage                         => $stage,

  }

}



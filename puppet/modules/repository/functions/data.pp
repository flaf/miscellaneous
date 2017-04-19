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

  $crdp_url                        = 'http://repository.crdp.ac-versailles.fr/debian'
  $crdp_gpgkey                     = 'http://repository.crdp.ac-versailles.fr/crdp.gpg'

  $crdp_gpgkey_fingerprint         = '741F A112 F3B2 D515 A885 93F8 3DE3 9DE9 78BB 3659'
  $puppet_apt_key_fingerprint      = '6F6B 1550 9CF8 E59E 6E46 9F32 7F43 8280 EF8D 349F'
  $ceph_apt_key_fingerprint        = '08B7 3419 AC32 B4E9 66C1 A330 E84A C2C0 460F 3994'
  $docker_apt_key_fingerprint      = '5811 8E89 F3A9 1289 7C07 0ADB F762 2157 2C52 609D'
  $gitlab_apt_key_fingerprint      = '1A4C 919D B987 D435 9396 38B9 1421 9A96 E15E 78F4'
  $hp_proliant_apt_key_fingerprint = '5744 6EFD E098 E5C9 34B6 9C7D C208 ADDE 26C2 B797'
  $postgresql_apt_key_fingerprint  = 'B97B 0AFC AA1A 47F0 44F2 44A0 7FCC 7D46 ACCC 4CF8'

  $sd                              = 'supported_distributions'
  $default_sd                      = [
                                      'trusty',
                                      'xenial',
                                      'jessie',
                                     ];

  {
    repository::aptconf::params::apt_proxy          => undef,
    repository::aptconf::params::install_recommends => false,
    repository::aptconf::params::install_suggests   => false,
    repository::aptconf::params::distrib_url        => $distrib_url,
    repository::aptconf::params::src                => false,
    repository::aptconf::params::backports          => false,
   "repository::aptconf::params::${sd}"             => $default_sd,

    repository::aptkey::params::http_proxy => undef,
    repository::aptkey::params::keyserver  => 'hkp://keyserver.ubuntu.com:80',
   "repository::aptkey::params::${sd}"     => $default_sd,

    repository::puppet::params::url                    => 'http://apt.puppetlabs.com',
    repository::puppet::params::src                    => false,
    repository::puppet::params::collection             => undef,
    repository::puppet::params::pinning_agent_version  => undef,
    repository::puppet::params::apt_key_fingerprint    => $puppet_apt_key_fingerprint,
   "repository::puppet::params::${sd}"                 => $default_sd,

    repository::mco::params::url                 => $crdp_url,
    repository::mco::params::key_url             => $crdp_gpgkey,
    repository::mco::params::apt_key_fingerprint => $crdp_gpgkey_fingerprint,
   "repository::mco::params::${sd}"              => $default_sd,

    repository::shinken::params::url                 => $crdp_url,
    repository::shinken::params::key_url             => $crdp_gpgkey,
    repository::shinken::params::apt_key_fingerprint => $crdp_gpgkey_fingerprint,
   "repository::shinken::params::${sd}"              => $default_sd,

    repository::postgresql::params::url                 => 'http://apt.postgresql.org/pub/repos/apt/',
    repository::postgresql::params::src                 => false,
    repository::postgresql::params::apt_key_fingerprint => $postgresql_apt_key_fingerprint,
   "repository::postgresql::params::${sd}"              => [ 'trusty' ],

    repository::puppetserver::params::pinning_puppetserver_version     => undef,
    repository::puppetserver::params::pinning_puppetdb_version         => undef,
    repository::puppetserver::params::pinning_puppetdb_termini_version => undef,
   "repository::puppetserver::params::${sd}"                           => [ 'trusty' ],

    repository::ceph::params::url                 => 'http://download.ceph.com',
    repository::ceph::params::src                 => false,
    repository::ceph::params::apt_key_fingerprint => $ceph_apt_key_fingerprint,
    repository::ceph::params::codename            => undef,
    repository::ceph::params::pinning_version     => undef,
   "repository::ceph::params::${sd}"              => [ 'trusty', 'jessie' ],

    repository::gitlab::params::url                 => "http://packages.gitlab.com/gitlab/gitlab-ce/${distro_id}/",
    repository::gitlab::params::src                 => false,
    repository::gitlab::params::apt_key_fingerprint => $gitlab_apt_key_fingerprint,
    repository::gitlab::params::pinning_version     => undef,
   "repository::gitlab::params::${sd}"              => [ 'trusty' ],

    repository::moobot::params::url                 => $crdp_url,
    repository::moobot::params::key_url             => $crdp_gpgkey,
    repository::moobot::params::apt_key_fingerprint => $crdp_gpgkey_fingerprint,
   "repository::moobot::params::${sd}"              => [ 'trusty', 'jessie' ],

    repository::proxmox::params::url    => 'http://download.proxmox.com/debian',
   "repository::proxmox::params::${sd}" => [ 'jessie' ],

    repository::raid::params::url                 => $crdp_url,
    repository::raid::params::key_url             => $crdp_gpgkey,
    repository::raid::params::apt_key_fingerprint => $crdp_gpgkey_fingerprint,
   "repository::raid::params::${sd}"              => [ 'trusty', 'jessie' ],

    repository::hp_proliant::params::url                 => 'http://downloads.linux.hpe.com/SDR/repo/mcp',
    repository::hp_proliant::params::apt_key_fingerprint => $hp_proliant_apt_key_fingerprint,
   "repository::hp_proliant::params::${sd}"              => [ 'trusty', 'jessie' ],

    repository::docker::params::url                 => 'http://apt.dockerproject.org/repo',
    repository::docker::params::src                 => false,
    repository::docker::params::apt_key_fingerprint => $docker_apt_key_fingerprint,
    repository::docker::params::pinning_version     => undef,
   "repository::docker::params::${sd}"              => [ 'trusty', 'jessie' ],

    repository::jrds::params::url                 => $crdp_url,
    repository::jrds::params::key_url             => $crdp_gpgkey,
    repository::jrds::params::apt_key_fingerprint => $crdp_gpgkey_fingerprint,
   "repository::jrds::params::${sd}"              => [ 'trusty', 'jessie' ],

    repository::php::params::url                 => $crdp_url,
    repository::php::params::key_url             => $crdp_gpgkey,
    repository::php::params::apt_key_fingerprint => $crdp_gpgkey_fingerprint,
   "repository::php::params::${sd}"              => [ 'trusty', 'jessie' ],

  }

}



class repository::docker (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::repository::docker::params']) {
    include '::repository::docker::params'
  }

  $url              = $::repository::docker::params::url
  $src              = $::repository::docker::params::src
  $pinning_version  = $::repository::docker::params::pinning_version

  if $pinning_version =~ Undef {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the parameter
      `repository::params::docker_pinning_version` is undefined.
      You must define it explicitly.
      |- END
  }

  $key      = '58118E89F3A912897C070ADBF76221572C52609D'
  $codename = $::facts['lsbdistcodename']
  $osid     = $::facts['lsbdistid'].downcase # typically "debian" or "ubuntu"
  $release  = "${osid}-${codename}"

  # Use hkp on port 80 to avoid problem with firewalls etc.
  apt::key { 'docker':
    id     => $key,
    server => 'hkp://keyserver.ubuntu.com:80',
  }

  apt::source { 'docker':
    comment  => 'Docker Repository.',
    location => $url,
    release  => $release,
    repos    => 'main',
    include  => { 'src' => $src, 'deb' => true },
    require  => Apt::Key['docker'],
  }

  if $pinning_version != 'none' {

    # About pinning => `man apt_preferences`.
    apt::pin { 'docker-engine':
      explanation => 'To ensure the version of the docker-engine package.',
      packages    => 'docker-engine',
      version     => $pinning_agent_version,
      priority    => 990,
    }

  }

}



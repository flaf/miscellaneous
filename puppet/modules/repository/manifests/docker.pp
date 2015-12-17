class repository::docker (
  String[1]           $url,
  Boolean             $src,
  String[1]           $pinning_version,
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

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



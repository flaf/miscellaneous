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

  apt::source { 'docker':
    comment  => 'Docker Repository.',
    location => $url,
    release  => $release,
    repos    => 'main',
    key      => $key,
    include  => { 'src' => $src, 'deb' => true },
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



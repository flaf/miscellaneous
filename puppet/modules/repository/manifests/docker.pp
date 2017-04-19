class repository::docker {

  include '::repository::docker::params'

  [
   $url,
   $src,
   $apt_key_fingerprint,
   $pinning_version,
   $supported_distributions,
  ] = Class['::repository::docker::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)
  ::homemade::fail_if_undef($pinning_version, 'pinning_version', $title)

  $key      = $apt_key_fingerprint
  $codename = $::facts['lsbdistcodename']
  $osid     = $::facts['lsbdistid'].downcase # typically "debian" or "ubuntu"
  $release  = "${osid}-${codename}"

  repository::aptkey { 'docker':
    id => $key,
  }

  repository::sourceslist { 'docker':
    comment    => 'Docker Repository.',
    location   => $url,
    release    => $release,
    components => [ 'main' ],
    src        => $src,
    require    => Repository::Aptkey['docker'],
  }

  if $pinning_version != 'none' {

    # About pinning => `man apt_preferences`.
    repository::pinning { 'docker-engine':
      explanation => 'To ensure the version of the docker-engine package.',
      packages    => 'docker-engine',
      version     => $pinning_agent_version,
      priority    => 990,
    }

  }

}



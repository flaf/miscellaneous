class repository::gitlab {

  include '::repository::gitlab::params'

  [
    $url,
    $src,
    $pinning_version,
    $supported_distributions,
  ] = Class['::repository::gitlab::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)
  ::homemade::fail_if_undef($pinning_version, 'pinning_version', $title)

  # GPG key which expires in 2020-04-15.
  $key      = '1A4C919DB987D435939638B914219A96E15E78F4'
  $codename = $::facts["os"]["distro"]["codename"].downcase()
  $comment  = "Gitlab Repository."

  repository::aptkey { 'gitlab':
    id => $key,
  }

  repository::sourceslist { "gitlab":
    comment    => $comment,
    location   => "${url}",
    release    => $codename,
    components => [ 'main' ],
    src        => $src,
    require    => Repository::Aptkey['gitlab'],
  }

  if $pinning_version != 'none' {

    # About pinning => `man apt_preferences`.
    repository::pinning { 'gitlab':
      explanation => 'To ensure the version of the gitlab-ce package.',
      packages    => 'gitlab-ce',
      version     => $pinning_version,
      priority    => 990,
    }

  }

}



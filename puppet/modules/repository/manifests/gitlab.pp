class repository::gitlab (
  String[1] $stage = 'repository',
) {

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

  # Use hkp on port 80 to avoid problem with firewalls etc.
  apt::key { 'gitlab':
    id     => $key,
    server => 'hkp://keyserver.ubuntu.com:80',
  }

  apt::source { "gitlab":
    comment  => $comment,
    location => "${url}",
    release  => $codename,
    repos    => 'main',
    include  => { 'src' => $src, 'deb' => true },
    require  => Apt::Key['gitlab'],
  }

  if $pinning_version != 'none' {

    # About pinning => `man apt_preferences`.
    apt::pin { 'gitlab':
      explanation => 'To ensure the version of the gitlab-ce package.',
      packages    => 'gitlab-ce',
      version     => $pinning_version,
      priority    => 990,
    }

  }

}



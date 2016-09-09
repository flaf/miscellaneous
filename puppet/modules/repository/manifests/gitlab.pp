class repository::gitlab (
  String[1] $stage = 'repository',
) {

  include '::repository::gitlab::params'

  $url                    = $::repository::gitlab::params::url
  $src                    = $::repository::gitlab::params::src
  $pinning_agent_version  = $::repository::gitlab::params::pinning_agent_version
  $pinning_server_version = $::repository::gitlab::params::pinning_server_version

  if $collection =~ Undef {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the parameter `repository::params::gitlab_collection`
      is undefined. You must define it explicitly.
      |- END
  }

  if $pinning_agent_version =~ Undef {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the parameter
      `repository::params::gitlab_pinning_agent_version` is undefined.
      You must define it explicitly.
      |- END
  }

  if $pinning_server_version =~ Undef {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the parameter
      `repository::params::gitlab_pinning_server_version` is undefined.
      You must define it explicitly.
      |- END
  }

  $key         = '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30'
  $collec_down = $collection.downcase
  $collec_up   = $collection.upcase
  $codename    = $::facts['lsbdistcodename']
  $comment     = "gitlablabs ${collec_up} ${codename} Repository."

  # Use hkp on port 80 to avoid problem with firewalls etc.
  apt::key { 'gitlablabs':
    id     => $key,
    server => 'hkp://keyserver.ubuntu.com:80',
  }

  apt::source { "gitlablabs-${collec_down}":
    comment  => $comment,
    location => "${url}",
    release  => $codename,
    repos    => $collec_up,
    include  => { 'src' => $src, 'deb' => true },
    require  => Apt::Key['gitlablabs'],
  }

  if $pinning_agent_version != 'none' {

    # About pinning => `man apt_preferences`.
    apt::pin { 'gitlab-agent':
      explanation => 'To ensure the version of the gitlab-agent package.',
      packages    => 'gitlab-agent',
      version     => $pinning_agent_version,
      priority    => 990,
    }

  }

  if $pinning_server_version != 'none' {

    # About pinning => `man apt_preferences`.
    apt::pin { 'gitlabserver':
      explanation => 'To ensure the version of the gitlabserver package.',
      packages    => 'gitlabserver',
      version     => $pinning_server_version,
      priority    => 990,
    }

  }

}



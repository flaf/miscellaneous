class repository::puppet (
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  include '::repository::params'
  $url                    = $::repository::params::puppet_url
  $src                    = $::repository::params::puppet_src
  $collection             = $::repository::params::puppet_collection
  $pinning_agent_version  = $::repository::params::puppet_pinning_agent_version
  $pinning_server_version = $::repository::params::puppet_pinning_server_version

  if $collection == 'NOT-DEFINED' {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the default value of the parameter
      `repository::params::puppet_collection` is not valid.
      You must define it explicitly.
      |- END
  }

  if $pinning_agent_version == 'NOT-DEFINED' {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the default value of the parameter
      `repository::params::puppet_pinning_agent_version` is not valid.
      You must define it explicitly.
      |- END
  }

  if $pinning_server_version == 'NOT-DEFINED' {
    regsubst(@("END"), '\n', ' ', 'G').fail
      $title: sorry the default value of the parameter
      `repository::params::puppet_pinning_server_version` is not valid.
      You must define it explicitly.
      |- END
  }

  $key         = '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30'
  $collec_down = $collection.downcase
  $collec_up   = $collection.upcase
  $codename    = $::facts['lsbdistcodename']
  $comment     = "Puppetlabs ${collec_up} ${codename} Repository."

  # Use hkp on port 80 to avoid problem with firewalls etc.
  apt::key { 'puppetlabs':
    id     => $key,
    server => 'hkp://keyserver.ubuntu.com:80',
  }

  apt::source { "puppetlabs-${collec_down}":
    comment  => $comment,
    location => "${url}",
    release  => $codename,
    repos    => $collec_up,
    include  => { 'src' => $src, 'deb' => true },
    require  => Apt::Key['puppetlabs'],
  }

  if $pinning_agent_version != 'none' {

    # About pinning => `man apt_preferences`.
    apt::pin { 'puppet-agent':
      explanation => 'To ensure the version of the puppet-agent package.',
      packages    => 'puppet-agent',
      version     => $pinning_agent_version,
      priority    => 990,
    }

  }

  if $pinning_server_version != 'none' {

    # About pinning => `man apt_preferences`.
    apt::pin { 'puppetserver':
      explanation => 'To ensure the version of the puppetserver package.',
      packages    => 'puppetserver',
      version     => $pinning_server_version,
      priority    => 990,
    }

  }

}



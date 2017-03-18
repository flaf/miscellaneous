class repository::puppet {

  include '::repository::puppet::params'

  [
   $url,
   $src,
   $apt_key_fingerprint,
   $collection,
   $pinning_agent_version,
   $supported_distributions,
  ] = Class['::repository::puppet::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ::homemade::fail_if_undef($collection, 'collection', $title)
  ::homemade::fail_if_undef($pinning_agent_version, 'pinning_agent_version', $title)

  $collec_down = $collection.downcase
  $collec_up   = $collection.upcase
  $codename    = $::facts['lsbdistcodename']
  $comment     = "Puppetlabs ${collec_up} ${codename} Repository."

  repository::aptkey { 'puppetlabs':
    id => $apt_key_fingerprint,
  }

  repository::sourceslist { "puppetlabs-${collec_down}":
    comment    => $comment,
    location   => "${url}",
    release    => $codename,
    components => [ $collec_up ],
    src        => $src,
    require    => Repository::Aptkey['puppetlabs'],
  }

  if $pinning_agent_version != 'none' {

    # About pinning => `man apt_preferences`.
    repository::pinning { 'puppet-agent':
      explanation => 'To ensure the version of the puppet-agent package.',
      packages    => 'puppet-agent',
      version     => $pinning_agent_version,
      priority    => 990,
    }

  }

}



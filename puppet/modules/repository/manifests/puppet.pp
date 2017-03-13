class repository::puppet {

  include '::repository::puppet::params'

  [
   $url,
   $src,
   $collection,
   $pinning_agent_version,
   $supported_distributions,
  ] = Class['::repository::puppet::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ::homemade::fail_if_undef($collection, 'collection', $title)
  ::homemade::fail_if_undef($pinning_agent_version, 'pinning_agent_version', $title)

  # PGP key which expires in 2019-02-11.
  $key         = '6F6B 1550 9CF8 E59E 6E46  9F32 7F43 8280 EF8D 349F'
  $collec_down = $collection.downcase
  $collec_up   = $collection.upcase
  $codename    = $::facts['lsbdistcodename']
  $comment     = "Puppetlabs ${collec_up} ${codename} Repository."

  repository::aptkey { 'puppetlabs':
    id => $key,
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



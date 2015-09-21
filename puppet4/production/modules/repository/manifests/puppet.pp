class repository::puppet (
  String[1]           $url,
  Boolean             $src,
  String[1]           $collection,
  String[1]           $pinning_agent_version,
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $key         = '47B320EB4C7C375AA9DAE1A01054B7A24BD6EC30'
  $collec_down = $collection.downcase
  $collec_up   = $collection.upcase
  $comment     = "Puppetlabs ${collec_up} ${::lsbdistcodename} Repository."

  apt::source { "puppetlabs-${collec_down}":
    comment     => $comment,
    location    => "${url}",
    release     => $::lsbdistcodename,
    repos       => $collec_up,
    key         => $key,
    include_src => $src,
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

}



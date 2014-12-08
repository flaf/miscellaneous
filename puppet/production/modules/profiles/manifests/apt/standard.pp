class profiles::apt::standard ($stage = 'repository', ) {

  # Should be equal to "debian" or "ubuntu".
  $os_family = downcase($::lsbdistid)

  $apt_conf        = hiera_hash('apt')
  $sourceslist_url = $apt_conf['official_repositories']['url'][$os_family]
  $add_src         = $apt_conf['official_repositories']['src']

  # Test if the data has been well retrieved.
  if $sourceslist_url == undef {
    fail("Problem in class ${title}, `sourceslist_url` data not retrieved.")
  }
  if $add_src == undef {
    fail("Problem in class ${title}, `add_src` data not retrieved.")
  }

  class { '::apt':
    purge_sources_list   => true,
    purge_sources_list_d => true,
  }

  case $::lsbdistcodename {

    wheezy: {

      apt::source { $::lsbdistcodename:
        comment     => 'Official repository.',
        location    => $sourceslist_url,
        release     => $::lsbdistcodename,
        repos       => 'main contrib non-free',
        include_deb => true,
        include_src => $add_src,
      }

      apt::source { "${::lsbdistcodename}-updates":
        comment     => 'Previously known as "volatile".',
        location    => $sourceslist_url,
        release     => "${::lsbdistcodename}-updates",
        repos       => 'main contrib non-free',
        include_deb => true,
        include_src => $add_src,
      }

      apt::source { "${::lsbdistcodename}-security":
        comment     => 'Security updates.',
        location    => 'http://security.debian.org/',
        release     => "${::lsbdistcodename}/updates",
        repos       => 'main contrib non-free',
        include_deb => true,
        include_src => $add_src,
      }

    }

    trusty: {

      apt::source { $::lsbdistcodename:
        comment     => 'main and restricted are maintained by the Ubuntu developers.',
        location    => $sourceslist_url,
        release     => $::lsbdistcodename,
        repos       => 'main restricted',
        include_deb => true,
        include_src => $add_src,
      }

      apt::source { "${::lsbdistcodename}-updates":
        comment     => 'Major bug fix updates produced after the final release of the distribution.',
        location    => $sourceslist_url,
        release     => "${::lsbdistcodename}-updates",
        repos       => 'main restricted',
        include_deb => true,
        include_src => $add_src,
      }

      apt::source { "${::lsbdistcodename}-security":
        comment     => 'Security updates.',
        location    => 'http://security.ubuntu.com/ubuntu',
        release     => "${::lsbdistcodename}-security",
        repos       => 'main restricted',
        include_deb => true,
        include_src => $add_src,
      }

    }

    default: {

      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")

    }

  } # End of "case".

}



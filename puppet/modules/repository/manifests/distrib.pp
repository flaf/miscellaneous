class repository::distrib (
  String[1]           $url,
  Boolean             $src,
  Boolean             $install_recommends,
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # Now, the sources.list, sources.list.d/ and preferences.d
  # are only managed by Puppet.
  class { '::apt':
    purge => { 'sources.list'   => true,
               'sources.list.d' => true,
               'preferences.d'  => true,
             },
  }

  # Set the "intall-recommends" options.
  # According to the documentation, the boolean $install_recommends
  # should be converted automatically to the string "true" or "false".
  # => https://docs.puppetlabs.com/puppet/latest/reference/lang_data_string.html#conversion-of-interpolated-values
  apt::setting { 'conf-InstallRecommends':
    content       => "APT::Install-Recommends \"${install_recommends}\";",
    ensure        => file,
    notify_update => false,
    priority      => '00',
  }

  case $::operatingsystem {

    'Debian': {

      apt::source { $::lsbdistcodename:
        comment     => 'Official repository.',
        location    => $url,
        release     => $::lsbdistcodename,
        repos       => 'main contrib non-free',
        include_deb => true,
        include_src => $src,
      }

      apt::source { "${::lsbdistcodename}-updates":
        comment     => 'Previously known as "volatile".',
        location    => $url,
        release     => "${::lsbdistcodename}-updates",
        repos       => 'main contrib non-free',
        include_deb => true,
        include_src => $src,
      }

      apt::source { "${::lsbdistcodename}-security":
        comment     => 'Security updates.',
        location    => 'http://security.debian.org/',
        release     => "${::lsbdistcodename}/updates",
        repos       => 'main contrib non-free',
        include_deb => true,
        include_src => $src,
      }

    }

    'Ubuntu': {

      apt::source { $::lsbdistcodename:
        comment     => 'Only main and restricted are maintained by the Ubuntu developers.',
        location    => $url,
        release     => $::lsbdistcodename,
        repos       => 'main restricted universe',
        include_deb => true,
        include_src => $src,
      }

      apt::source { "${::lsbdistcodename}-updates":
        comment     => 'Major bug fix updates produced after the final release of the distribution.',
        location    => $url,
        release     => "${::lsbdistcodename}-updates",
        repos       => 'main restricted universe',
        include_deb => true,
        include_src => $src,
      }

      apt::source { "${::lsbdistcodename}-security":
        comment     => 'Security updates.',
        location    => 'http://security.ubuntu.com/ubuntu',
        release     => "${::lsbdistcodename}-security",
        repos       => 'main restricted universe',
        include_deb => true,
        include_src => $src,
      }

    }

  } # End of "case".

}



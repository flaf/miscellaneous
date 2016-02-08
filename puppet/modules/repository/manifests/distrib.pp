class repository::distrib (
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  if !defined(Class['::repository::params']) { include '::repository::params' }
  $url                = $::repository::params::distrib_url
  $src                = $::repository::params::distrib_src
  $install_recommends = $::repository::params::distrib_install_recommends

  $codename = $::facts['lsbdistcodename']

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

      apt::source { $codename:
        comment  => 'Official repository.',
        location => $url,
        release  => $codename,
        repos    => 'main contrib non-free',
        include  => { 'src' => $src, 'deb' => true },
      }

      apt::source { "${codename}-updates":
        comment  => 'Previously known as "volatile".',
        location => $url,
        release  => "${codename}-updates",
        repos    => 'main contrib non-free',
        include  => { 'src' => $src, 'deb' => true },
      }

      apt::source { "${codename}-security":
        comment  => 'Security updates.',
        location => 'http://security.debian.org/',
        release  => "${codename}/updates",
        repos    => 'main contrib non-free',
        include  => { 'src' => $src, 'deb' => true },
      }

    }

    'Ubuntu': {

      apt::source { $codename:
        comment  => 'Only main and restricted are maintained by the Ubuntu developers.',
        location => $url,
        release  => $codename,
        repos    => 'main restricted universe',
        include  => { 'src' => $src, 'deb' => true },
      }

      apt::source { "${codename}-updates":
        comment  => 'Major bug fix updates produced after the final release of the distribution.',
        location => $url,
        release  => "${codename}-updates",
        repos    => 'main restricted universe',
        include  => { 'src' => $src, 'deb' => true },
      }

      apt::source { "${codename}-security":
        comment  => 'Security updates.',
        location => 'http://security.ubuntu.com/ubuntu',
        release  => "${codename}-security",
        repos    => 'main restricted universe',
        include  => { 'src' => $src, 'deb' => true },
      }

    }

  } # End of "case".

}



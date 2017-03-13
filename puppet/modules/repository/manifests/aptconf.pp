class repository::aptconf {

  include '::repository::aptconf::params'

  [
   $apt_proxy,
   $install_recommends,
   $install_suggests,
   $distrib_url,
   $src,
   $backports,
   $supported_distributions,
  ] = Class['::repository::aptconf::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $codename = $::facts['lsbdistcodename']

  if $::operatingsystem != 'Debian' and $backports {
    @("END").regsubst('\n', ' ', 'G').fail
      ${title}: if the parameter repository::aptconf::params::backports is
      set to true, the OS must be Debian but it is ${::operatingsystem}
      currently.
      |- END
  }

  # Now, the sources.list, sources.list.d/ and preferences.d
  # are only managed by Puppet.

  file { '/etc/apt/sources.list':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "### APT repositories managed by Puppet in /etc/apt/sources.list.d. ###\n",
    notify  => Exec['aptconf-base-update'],
  }

  file { '/etc/apt/sources.list.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    purge   => true,
    recurse => true,
    notify  => Exec['aptconf-base-update'],
  }

  file { '/etc/apt/preferences':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "### APT preferences managed by Puppet in /etc/apt/preferences.d. ###\n",
  }

  file { '/etc/apt/preferences.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    purge   => true,
    recurse => true,
  }

  file { '/etc/apt/apt.conf':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "// APT configuration _partially_ managed by Puppet in /etc/apt/apt.conf.d. //\n",
  }

  # Set the "intall-recommends" options.
  # According to the documentation, the boolean
  # $install_recommends should be converted automatically to
  # the string "true" or "false" in the string "content":
  #
  #     https://docs.puppetlabs.com/puppet/latest/reference/lang_data_string.html
  #     (see the section "Conversion of interpolated-values")
  #
  # After a PXE installation, the file /etc/apt/apt.conf.d/00InstallRecommends
  # already exists. So we keep the priority 00 in this specific case.
  file { '/etc/apt/apt.conf.d/00InstallRecommends':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "APT::Install-Recommends \"${install_recommends}\";\n",
  }

  file { '/etc/apt/apt.conf.d/80InstallSuggests':
    ensure  => file,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "APT::Install-Suggests \"${install_suggests}\";\n",
  }

  # An APT proxy can be just undefined.
  case $apt_proxy {
    undef: {
      $proxy_ensure  = 'absent'
      $proxy_content = undef
    }
    default: {
      $proxy_ensure  = 'file'
      $proxy_content = "Acquire::http::Proxy \"${apt_proxy}\";\n"
    }
  }

  file { '/etc/apt/apt.conf.d/80Proxy':
    ensure  => $proxy_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $proxy_content,
    notify  => Exec['aptconf-base-update'],
  }

  ### The "official" sources.list entries. ###
  case $::operatingsystem {

    'Debian': {

      repository::sourceslist { $codename:
        comment    => 'Official repository.',
        location   => $distrib_url,
        release    => $codename,
        components => [ 'main', 'contrib', 'non-free' ],
        src        => $src,
        apt_update => false,
        notify     => Exec['aptconf-base-update'],
      }

      repository::sourceslist { "${codename}-updates":
        comment    => 'Previously known as "volatile".',
        location   => $distrib_url,
        release    => "${codename}-updates",
        components => [ 'main', 'contrib', 'non-free' ],
        src        => $src,
        apt_update => false,
        notify     => Exec['aptconf-base-update'],
      }

      repository::sourceslist { "${codename}-security":
        comment    => 'Security updates.',
        location   => 'http://security.debian.org/',
        release    => "${codename}/updates",
        components => [ 'main', 'contrib', 'non-free' ],
        src        => $src,
        apt_update => false,
        notify     => Exec['aptconf-base-update'],
      }

      if $backports {
        repository::sourceslist { 'backports':
          comment    => 'Backports repository.',
          location   => $distrib_url,
          release    => "${codename}-backports",
          components => [ 'main', 'contrib', 'non-free' ],
          src        => $src,
          apt_update => false,
          notify     => Exec['aptconf-base-update'],
        }
      }

    }

    'Ubuntu': {

      repository::sourceslist { $codename:
        comment    => 'Only main and restricted are maintained by the Ubuntu developers.',
        location   => $distrib_url,
        release    => $codename,
        components => [ 'main', 'restricted', 'universe' ],
        src        => $src,
        apt_update => false,
        notify     => Exec['aptconf-base-update'],
      }

      repository::sourceslist { "${codename}-updates":
        comment    => 'Major bug fix updates produced after the final release of the distribution.',
        location   => $distrib_url,
        release    => "${codename}-updates",
        components => [ 'main', 'restricted', 'universe' ],
        src        => $src,
        apt_update => false,
        notify     => Exec['aptconf-base-update'],
      }

      repository::sourceslist { "${codename}-security":
        comment    => 'Security updates.',
        location   => 'http://security.ubuntu.com/ubuntu',
        release    => "${codename}-security",
        components => [ 'main', 'restricted', 'universe' ],
        src        => $src,
        apt_update => false,
        notify     => Exec['aptconf-base-update'],
      }

    }

  } # End of "case".

  exec { 'aptconf-base-update':
    command     => 'apt-get update',
    user        => 'root',
    group       => 'root',
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    logoutput   => 'on_failure',
    refreshonly => true,
    timeout     => 40,
    tries       => 1,
    try_sleep   => 2,
  }

}



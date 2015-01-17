# ==Action
# Various Debian-ralated stuff
#
class debian {
  $locales = hiera_hash('locales')
  $keyboard = hiera_hash('keyboard')

  # set mailname
  file { '/etc/mailname':
    content => $fqdn,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  # set 'update-alternative --config editor' to 'vim'
  file { '/etc/alternatives/editor':
    ensure  => '/usr/bin/vim.basic',
    require => Package['vim'],
  }

  # Always set default locale to en_US.UTF-8 (reconfigure locale if required)
  file { "/var/local/preseed/locales.preseed":
    content => template('debian/locales.preseed.erb'),
    require => File['/var/local/preseed'],
    notify  => Exec['reconfigure-locales'],
  }

  exec { 'reconfigure-locales':
    command     => 'rm -f /etc/locale.gen && debconf-set-selections </var/local/preseed/locales.preseed && \
                    dpkg-reconfigure -f noninteractive locales && update-locale LANG=en_US.UTF-8',
    path        => '/bin:/usr/sbin:/usr/bin',
    # unless => "grep 'en_US.UTF-8' /etc/default/locale",
    refreshonly => true,
    logoutput   => on_failure,
    timeout     => 0,
    require     => File['/var/local/preseed/locales.preseed'],
  }

  # Presseds
  file { '/var/local/preseed':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0700',
  }

  # Configure physical keyboard

  file { '/etc/default/keyboard':
    content => template('debian/keyboard.default.erb'),
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    notify  => Exec['restart-keyboard-setup'],
  }

  exec { 'restart-keyboard-setup':
    command     => '/usr/bin/test -x /etc/init.d/keyboard-setup && /etc/init.d/keyboard-setup restart || true',
    refreshonly => true,
  } 

  define preseed_package ($ensure, $source) {
    file { "/var/local/preseed/$name.preseed":
      ensure  => present,
      require => File['/var/local/preseed'],
      content => template($source),
      owner   => 'root',
      group   => 'root',
      mode    => '0400',
    }

    package { "$name":
      ensure       => installed,
      require      => File["/var/local/preseed/${name}.preseed"],
      responsefile => "/var/local/preseed/${name}.preseed"
    }
  }
}

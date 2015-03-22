class puppetmaster::packages {

  private("Sorry, ${title} is a private class.")

  $packages = [
                'git',
                'openssl',
                'ca-certificates',
                'puppetmaster-passenger',
                'puppetdb',
                'puppetdb-terminus',
                'postgresql',
                'postgresql-contrib',
              ]

  ensure_packages($packages, { ensure => present, })

  # With Trusty, the init symlinks of puppetdb are not created
  # after the package installation.
  if $::lsbdistcodename == 'trusty' {

    exec { 'add-init-symlinks-for-puppetdb':
      command => 'update-rc.d puppetdb defaults',
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      user    => 'root',
      group   => 'root',
      require => Package['puppetdb'],
      unless  => 'ls -1 /etc/rc?.d | grep -q "puppetdb$"',
    }

  }
}



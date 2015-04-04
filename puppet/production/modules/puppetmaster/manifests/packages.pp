class puppetmaster::packages {

  private("Sorry, ${title} is a private class.")

  $packages = [
                'git',
                'openssl',
                'ca-certificates',
                'puppetmaster-passenger',
                'puppetdb-terminus',
              ]

  ensure_packages($packages, { ensure => present, })

  if $puppetdb_server == '<my-self>' {

    # Supplementary package is the host provides a puppetdb service.
    ensure_packages( [ 'postgresql',
                       'postgresql-contrib',
                       'puppetdb'],
                     { ensure => present, }
                   )

    # puppetdb and puppetdb-terminus must be installed after
    # puppetmaster-passenger, because in this case the postinst
    # of puppetdb configure Jetty to use the puppetmaster's certificates.
    Package['puppetmaster-passenger'] -> Package['puppetdb']
                                      -> Package['puppetdb-terminus']
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

}



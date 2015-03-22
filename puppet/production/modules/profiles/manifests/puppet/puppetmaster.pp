class profiles::puppet::puppetmaster {

  class { '::puppetmaster':
    server               => 'sumsum.flaf.fr',
    #puppetdb_user => 'joe',
    #admin_email   => 'sysadmin@domain.tld',
    hiera_git_repository => 'git@github.com:flaf/test-hiera.git',
  }

}



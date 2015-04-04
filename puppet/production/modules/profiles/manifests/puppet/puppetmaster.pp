class profiles::puppet::puppetmaster {

  class { '::puppetmaster':
    #server               => $server,
    #ca_server            => $ca_server,
    environment_timeout  => '0s',
    #puppetdb_user => 'joe',
    #admin_email   => 'sysadmin@domain.tld',
    hiera_git_repository => 'git@github.com:flaf/test-hiera.git',
  }

}



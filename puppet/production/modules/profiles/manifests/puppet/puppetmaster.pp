class profiles::puppet::puppetmaster {

  class { '::puppetmaster':
    server        => 'sumsum.flaf.fr',
    puppetdb_pwd  => 'AZERTY',
    puppetdb_user => 'joe',
    admin_email   => 'sysadmin@domain.tld',
  }

}



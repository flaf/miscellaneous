class profiles::puppet::puppetmaster {

  class { '::puppetmaster':
    puppetdb_pwd  => 'AZERTY',
    puppetdb_user => 'joe',
  }

}



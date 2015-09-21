function basic_ssh::data {

  { basic_ssh::server::permitrootlogin         => 'yes',
    basic_ssh::server::supported_distributions => ['trusty', 'jessie'],
    basic_ssh::client::supported_distributions => ['trusty', 'jessie'],
  }

}



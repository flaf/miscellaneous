function basic_ssh::data {

  {
    basic_ssh::server::permitrootlogin         => 'without-password',
    basic_ssh::server::supported_distributions => ['trusty', 'jessie'],
    basic_ssh::client::supported_distributions => ['trusty', 'jessie'],
  }

}



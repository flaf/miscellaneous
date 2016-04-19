function basic_ssh::data {

  $default_distribs = ['trusty', 'jessie']
  $sd               = 'supported_distributions';

  {
    basic_ssh::server::params::permitrootlogin => 'without-password',
   "basic_ssh::server::params::${sd}"          => $default_distribs,

   "basic_ssh::client::params::${sd}" => $default_distribs,
  }

}



function locale::data {

  $sd = 'supported_distributions';

  {
    locale::params::default_locale  => 'en_US.UTF-8',
   "locale::params::${sd}"          => ['trusty', 'jessie'],
  }

}



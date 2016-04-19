function keyboard::data {

  $sd = 'supported_distributions';

  {
    keyboard::params::xkbmodel   => 'pc105',
    keyboard::params::xkblayout  => 'fr',
    keyboard::params::xkbvariant => 'latin9',
    keyboard::params::xkboptions => '',
    keyboard::params::backspace  => 'guess',
   "keyboard::params::${sd}"     => ['trusty', 'jessie'],
  }

}



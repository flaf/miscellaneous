function keyboard::data {

  $defaults = {
    keyboard::xkbmodel   => 'pc105',
    keyboard::xkblayout  => 'fr',
    keyboard::xkbvariant => 'latin9',
    keyboard::xkboptions => '',
    keyboard::backspace  => 'guess',
  }

  $params = lookup('keyboard', Hash, hash, $defaults);

  {
    keyboard::xkbmodel   => $params['xkbmodel'],
    keyboard::xkblayout  => $params['xkblayout'],
    keyboard::xkbvariant => $params['xkbvariant'],
    keyboard::xkboptions => $params['xkboptions'],
    keyboard::backspace  => $params['backspace'],
  }

}



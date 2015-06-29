function keyboard::data {

  $defaults = {
    xkbmodel   => 'pc105',
    xkblayout  => 'fr',
    xkbvariant => 'latin9',
    xkboptions => '',
    backspace  => 'guess',
  }

  $params = lookup('keyboard', Hash, hash, $defaults)

  {
    keyboard::xkbmodel   => $params['xkbmodel'],
    keyboard::xkblayout  => $params['xkblayout'],
    keyboard::xkbvariant => $params['xkbvariant'],
    keyboard::xkboptions => $params['xkboptions'],
    keyboard::backspace  => $params['backspace'],
  }

}



function keyboard::data {

  $v = 'eee'

  {
    keyboard::xkbmodel   => 'pc105',
    keyboard::xkblayout  => 'fr',
    keyboard::xkbvariant => 'latin9',
    keyboard::xkboptions => '',
    keyboard::backspace  => 'guess',
  }



  #$params = {
  #  xkbmodel   => 'pc105',
  #  xkblayout  => 'fr',
  #  xkbvariant => 'latin9',
  #  xkboptions => '',
  #  backspace  => 'guess',
  #}

  ##$params = lookup('keyboard', Hash, merge, $defaults)

  #{
  #  keyboard::xkbmodel   => $params['xkbmodel'],
  #  keyboard::xkblayout  => $params['xkblayout'],
  #  keyboard::xkbvariant => $params['xkbvariant'],
  #  keyboard::xkboptions => $params['xkboptions'],
  #  keyboard::backspace  => $params['backspace'],
  #}

}



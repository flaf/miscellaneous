class profile_keyboard (
  $stage = 'basis',
) {

  $keyboard_conf = hiera_hash('keyboard')

  class { '::keyboard':
    xkbmodel   => $keyboard_conf['xkbmodel'],
    xkblayout  => $keyboard_conf['xkblayout'],
    xkbvariant => $keyboard_conf['xkbvariant'],
  }

}



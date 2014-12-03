class profiles::keyboard::standard {

  $keyboard   = hiera('keyboard')

  $xkbmodel   = $keyboard['xkbmodel']
  $xkblayout  = $keyboard['xkblayout']
  $xkbvariant = $keyboard['xkbvariant']

  # Test if the data has been well retrieved.
  if $xkbmodel == undef {
    fail("Problem in class ${title}, `xkbmodel` data not retrieved")
  }
  if $xkblayout == undef {
    fail("Problem in class ${title}, `xkblayout` data not retrieved")
  }
  if $xkbvariant == undef {
    fail("Problem in class ${title}, `xkbvariant` data not retrieved")
  }

  class { '::keyboard':
    xkbmodel   => $xkbmodel,
    xkblayout  => $xkblayout,
    xkbvariant => $xkbvariant,
  }

}



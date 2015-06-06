stage { 'basis':
  before => Stage['network'],
}

stage { 'network':
  before => Stage['repository'],
}

stage { 'repository':
  before => Stage['main'],
}

# We assume that the $role variable is already defined by the ENC.
class { '::include_role':
  role => $role,
}


class {'network::interfaces':
  interfaces => {
                  'eth1' => {
                              'macaddress' => 'ccc',
                              'method'     => 'static',
                              'comment'    => 'blabla',
                              'options' => { 'zbkey1' => 'val1', 'aaakey2' => 'val2' },
                            },
                  'eth0' => {
                              'macaddress' => 'aaa',
                              'method'     => 'static',
                              'comment'    => 'blabla',
                              'options' => { 'bkey1' => 'val1', 'aaakey2' => 'val2' },
                            },
                }
}


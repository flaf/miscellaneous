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
                  'eth0' => {
                              'macaddress' => 'aaa',
                              'method'     => 'static',
                            },
                }
}


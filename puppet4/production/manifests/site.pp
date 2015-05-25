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
class { '::main':
  role => $role,
}



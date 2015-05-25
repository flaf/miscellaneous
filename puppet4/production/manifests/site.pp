# We assume that the $role variable is already defined by the ENC.
class { '::main':
  role => $role,
}



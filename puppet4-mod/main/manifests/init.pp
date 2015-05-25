$extlookup_datadir    = "/etc/puppet/extdata"
$extlookup_precedence = ['common']

stage { 'basis':
  before => Stage['network'],
}

stage { 'network':
  before => Stage['repository'],
}

stage { 'repository':
  before => Stage['main'],
}

# The "role" attribute must be a non empty string.
class main (
  String[1] $role
) {

  include $role

}



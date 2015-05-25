# Lookup of CSV data.
$extlookup_datadir    = "/etc/puppet/extdata"
$extlookup_precedence = ['common']

# Some stages.
stage { 'basis':
  before => Stage['network'],
}

stage { 'network':
  before => Stage['repositories'],
}

stage { 'repositories':
  before => Stage['main'],
}

# Include the role of the node.
$role = hiera('enc_role')
validate_string($role)

if empty($role) {

  fail("The value in hiera of enc_role for ${::fqdn} is an empty string.")

} else {

  include($role)

}



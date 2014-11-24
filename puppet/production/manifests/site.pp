$extlookup_datadir = "/etc/puppet/extdata"
$extlookup_precedence = ["common"]

stage { 'network': }
Stage['base_packages'] -> Stage['main']

hiera_include('classes')



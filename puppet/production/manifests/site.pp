$extlookup_datadir = "/etc/puppet/extdata"
$extlookup_precedence = ["common"]

stage { 'network': }
Stage['network'] -> Stage['main']

hiera_include('classes')



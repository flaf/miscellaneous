$extlookup_datadir = "/etc/puppet/extdata"
$extlookup_precedence = ["common"]

stage { 'network': }
stage { 'basis': }

Stage['basis']
  -> Stage['network']
  -> Stage['main']

hiera_include('classes')



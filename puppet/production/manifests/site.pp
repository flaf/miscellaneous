$extlookup_datadir = "/etc/puppet/extdata"
$extlookup_precedence = ["common"]

stage { 'basis': }
stage { 'network': }

Stage['basis']
  -> Stage['network']
  -> Stage['main']

hiera_include('classes')



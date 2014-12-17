$extlookup_datadir = "/etc/puppet/extdata"
$extlookup_precedence = ["common"]

stage { 'basis': }
stage { 'network': }
stage { 'repository': }

Stage['basis']
  -> Stage['network']
  -> Stage['repository']
  -> Stage['main']

hiera_include('classes')



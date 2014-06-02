$extlookup_datadir = "/etc/puppet/extdata"
$extlookup_precedence = ["common"]


stage { 'base_packages': }
stage { 'last': }

Stage['base_packages']
  -> Stage['main']
  -> Stage['last']

hiera_include('classes')



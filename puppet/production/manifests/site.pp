$extlookup_datadir = "/etc/puppet/extdata"
$extlookup_precedence = ['common']

stage { 'basis': }
stage { 'network': }
stage { 'repositories': }

Stage['basis']
  -> Stage['network']
  -> Stage['repositories']
  -> Stage['main']

hiera_include('classes')



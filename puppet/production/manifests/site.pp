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


ini_setting { "sample setting":
  ensure  => absent,
  path    => '/tmp/a.ini',
  section => 'ccc',
  #setting => 'c3',
  #value   => 'super new!!!!!!',
}



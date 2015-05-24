$extlookup_datadir    = "/etc/puppet/extdata"
$extlookup_precedence = ['common']

stage { 'basis': }
stage { 'network': }
stage { 'repositories': }

Stage['basis']
  -> Stage['network']
  -> Stage['repositories']
  -> Stage['main']

$classes = hiera_array('enc_class', '<empty>')

if $classes == '<empty>' {

  notify {'no-class-found':
    message => 'Sorry, no class found for this node.',
  }

} else {

  hiera_include('enc_class')

}



# This file is managed by Puppet, don't edit it.

$extlookup_datadir    = "/etc/puppet/extdata"
$extlookup_precedence = [ 'common', ]

stage { 'basis': }
stage { 'network': }
stage { 'repositories': }
stage { 'kernel': }

Stage['basis']
  -> Stage['network']
  -> Stage['repositories']
  -> Stage['kernel']
  -> Stage['main']

$classes = hiera_hash('enc_class', '<empty>')

if $classes == '<empty>' {

  notify {'no-class-found':
    message => 'Sorry, no class found for this node.',
  }

} else {

  hiera_include('enc_class')

}



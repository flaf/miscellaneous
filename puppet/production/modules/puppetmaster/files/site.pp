# This file is managed by Puppet, don't edit it.

stage { 'basis': }
stage { 'network': }
stage { 'repositories': }
stage { 'kernel': }

Stage['basis']
  -> Stage['network']
  -> Stage['repositories']
  -> Stage['kernel']
  -> Stage['main']

hiera_include('enc_class')



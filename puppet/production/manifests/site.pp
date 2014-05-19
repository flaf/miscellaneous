stage { 'base_packages': }
stage { 'last': }

Stage['base_packages']
  -> Stage['main']
  -> Stage['last']

hiera_include('classes')



class hosts::collect {

  require '::hosts'

  if $tag == undef {
    fail("Class ${title}, you must provide the `tag` parameter.")
  }

  File <<| tag == $tag and tag == 'hosts::entry' |>> {
    notify  => Class['::hosts::refresh'],
  }

}



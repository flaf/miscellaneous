class hosts::collect {

  require '::hosts'

  if $tag == undef {
    fail("Class ${title}, you must provide the `tag` parameter.")
  }

  # In this module, $tag must be a string.
  validate_string($tag)

  # "@xxx" variables are allowed in tag string.
  $tag_expanded = inline_template(str2erb($tag))

  File <<| tag == $tag_expanded and tag == 'hosts::entry' |>> {
    notify  => Class['::hosts::refresh'],
  }

}



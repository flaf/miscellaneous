# TODO: write documentation.
#       Impossible to use the metaparameter because
#       "@datacenter-foo" is invalid tag for puppet.
#       Depends on puppetlabs-stdlib and homemade_functions
#       modules.
#
class hosts::collect (
  $magic_tag = undef,
) {

  require '::hosts'

  if $magic_tag == undef {
    fail("Class ${title}, you must provide the `magic_tag` parameter.")
  }

  # In this module, $magic_tag must be a string.
  validate_string($magic_tag)

  # "@xxx" variables are allowed in $magic_tag string.
  $tag_expanded = inline_template(str2erb($magic_tag))

  File <<| tag == $tag_expanded and tag == 'hosts::entry' |>> {
    notify  => Class['::hosts::refresh'],
  }

}



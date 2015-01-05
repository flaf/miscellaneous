# A class to collect the exported hosts entries.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib and homemade_functions
# modules.
#
# == Parameters
#
# *magic_tag:*
# This parameter must be a string to select the exported
# hosts entries which will be collected. Impossible to use
# directly the metaparameter "tag" because strings like
# "@datacenter-foo" are invalid tag for puppet. On the
# contrary, this string is valid for the magic_tag parameter
# and will be expanded. This parameter is mandatory and has
# no default value.
#
# == Sample Usages
#
#  $tag = '@datacenter-cluster-foo'
#
#  '::hosts::entry' { 'self':
#    address   => '@ipaddress',
#    hostnames => [ '@fqdn' ],
#    exported  => true,
#    magic_tag => $tag,
#  }
#
#  class { '::hosts::collect':
#    magic_tag => $tag,
#  }
#
class hosts::collect (
  $magic_tag,
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



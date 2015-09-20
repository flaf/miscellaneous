stage { 'basis': }
stage { 'network': }
stage { 'repository': }

Stage['basis'] -> Stage['network']
               -> Stage['repository']
               -> Stage['main']

# We assume that the $::included_classes variable must
# be defined by the ENC and must be a non-empty array of
# non-empty string(s) where each string has this form:
#
#   (<author>)-<fully-qualified-class-name>
#
# For instance:
#
#   (bob)::apache2::vhosts
#
# where, is this case, the class `::apache2::vhosts` will
# be included to the catalogue.
#
if $::included_classes =~ Array[String[1], 1] {

  $::included_classes.each |$a_class| {

    $regex_class_name = /^\([a-z0-9]+\)((::[a-z0-9][_a-z0-9]*)+)$/

    if $a_class =~ $regex_class_name {

      $a_class_without_author = $a_class.regsubst($regex_class_name, '\1')
      include $a_class_without_author

    } else {

      $msg_bad_name = @(END).regsubst('\n', ' ', 'G').regsubst('CLASSNAME', $a_class)
        Sorry, the `$::included_classes` global variable is defined
        with the correct type but each string of this array must have
        this form `(<author>)<fully-qualified-class-name>` and this is
        not the case currently with this element of the array: `CLASSNAME`.
        |- END
      fail($msg_bad_name)

    }

  }

} else {

  $msg_not_defined = @(END).regsubst('\n', ' ', 'G')
      Sorry, the node must have a `$::included_classes` global
      variable defined (for instance by the ENC) and it must be
      an non-empty array of non-empty string(s).
      |- END
  fail($msg_not_defined)

}



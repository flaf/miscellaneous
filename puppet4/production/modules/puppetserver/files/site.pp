### This file is managed by Puppet, please don't edit it. ###

stage { 'basis': }
stage { 'network': }
stage { 'repository': }

Stage['basis'] -> Stage['network']
               -> Stage['repository']
               -> Stage['main']

# We assume that the $::included_classes variable must
# be defined by the ENC and must be a non-empty array of
# element with this form:
#
#   [ '<author>', '<fully-qualified-class-name>' ]
#
# Yes, each element is an array. For instance:
#
#   $::included_classes = [
#                          ['bob', '::apache2::vhosts' ],
#                          ['joe', '::rsyslog' ],
#                         ]
#
# where, in this case, the classes `::apache2::vhosts`
# and `::rsyslog` will be included to the catalogue
# from the modules `bob-apache2` and `joe-rsyslog`.


if $::included_classes =~ Array[Array[String[1], 2, 2], 1] {

  $::included_classes.each |$author_class| {

    $the_class = $author_class[1]
    include $the_class

  }

} else {

  $msg_not_defined = @(END).regsubst('\n', ' ', 'G')
      Sorry, the node must have a `$::included_classes` global
      variable defined (for instance by the ENC) and it must be
      an non-empty array of elements with this form
      `[ '<author>', '<fully-qualified-class-name>' ]`
      |- END
  fail($msg_not_defined)

}



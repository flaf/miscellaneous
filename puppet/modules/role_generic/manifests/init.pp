class role_generic {

  if !defined(Class['::role_generic::params']) {
      include '::role_generic::params'
  }

  $supported_classes = $::role_generic::params::supported_classes
  $excluded_classes  = $::role_generic::params::excluded_classes
  $included_classes  = $::role_generic::params::included_classes

  # All classes in $excluded_classes must belong to the
  # $supported_classes array. The goal is to avoid a case
  # where the user wants to exclude a class but he makes a
  # misprint in its name and the real class is not excluded.
  $excluded_classes.each |$a_class| {
    unless $a_class in $supported_classes {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: you want to exclude the class `${a_class}` from the
        module `${title}` but this class does not belong to the list of
        classes supported by this module. Are you sure you have not made
        a misprint?
        |- END
    }
  }

  # We check that all classes in $included_classes are in
  # $supported_classes.
  $included_classes.each |$a_class| {
    unless $a_class in $supported_classes {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: you want to include the class `${a_class}` from the
        module `${title}` but this class does not belong to the list of
        classes supported by this module. Are you sure you have not made
        a misprint?
        |- END
    }
  }

  $remaining_classes = $included_classes - $excluded_classes

  $remaining_classes.each |String[1] $a_class| {
    include $a_class
  }

}



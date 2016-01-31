class role_generic (
  Array[String[1]] $excluded_classes,
) {

  # Classes applied by default.
  $included_classes = [
    '::unix_accounts',
    '::network',
    '::network::hosts',
    '::network::resolv_conf',
    '::network::ntp',
    '::repository::distrib',
    '::raid',
    '::basic_ssh::server',
    '::basic_ssh::client',
    '::basic_packages',
    '::keyboard',
    '::locale',
    '::timezone',
    '::puppetagent',
    '::mcollective::server',
    '::snmp',
  ]

  # All classes in $excluded_classes must belong to the
  # $included_classes array. The goal is to avoid a case
  # where the user wants to exclude a class but but makes a
  # misprint in its name (and the real class is not
  # excluded).
  $excluded_classes.each |$a_class| {
    if ! $included_classes.member($a_class) {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: you want to exclude the class `${$a_class}` from the
        module `${title}` but this class does not belong to the list of
        classes applied by this module. Are you sure you have not made
        a typo?
        |- END
    }
  }

  # Classes are applied except the classes in the
  # $excluded_classes array.
  $included_classes.each |$a_class| {
    if ! $excluded_classes.member($a_class) {
      include $a_class
    }
  }

}



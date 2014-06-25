class shinken::node::params {

  require 'shinken::common::params'

  $exported_dir         = $shinken::common::params::exported_dir
  $tag                  = $shinken::common::params::tag

  $additional_templates = hiera_array('shinken_node_templates', undef)
  $properties           = hiera_hash('shinken_node_properties', undef)
  $disable_ipmi_check   = hiera('disable_ipmi_check', 'false')

  # This package is necessary to have the facters
  # "boardmanufacturer" and "boardproductname".
  package { 'dmidecode':
    ensure => present,
  }

  # Unfortunately, the facters "boardmanufacturer" and
  # "boardproductname" are not defined in Lenny and
  # Squeeze (for Wheezy yes). We are forced to use custom
  # facts.
  if ($lsbdistcodename == 'lenny') or ($lsbdistcodename == 'squeeze') {

    if ($motherboard_manufacturer != '') {
      $boardmanufacturer = $motherboard_manufacturer
    }

    if ($motherboard_productname != '') {
      $boardproductname = $motherboard_productname
    }

  }

  # If these facters are defined, the host has probably a motherboard.
  if ($boardmanufacturer != undef) and ($boardproductname != undef) {
    $has_motherboard = 'true'
  } else {
    $has_motherboard = 'false'
  }

  # Test which template will be use (or not) for the ipmi check.
  if ($has_motherboard == 'true') {
    # check with "ipmi-sensors_tpl" only if the distribution is not
    # lenny or squeeze.
    if ($lsbdistcodename != 'lenny') and ($lsbdistcodename != 'squeeze') {
      $ipmi_sensors_tpl = 'true'
    } else {
      $ipmi_sensors_tpl = 'false'
    }
  } else {
    $ipmi_sensors_tpl = 'false'
  }

}



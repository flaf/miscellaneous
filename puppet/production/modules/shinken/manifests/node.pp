#==Action
#
# Install and configure SNMP in a Shinken node which will be
# checked by the shinken server.
# Tested with Debian Wheezy.
#
# This class depends on:
# - repositories::shinken to add a repository made in CRDP in the APT configuration.
# - snmp::snmpd to configure the snmpd daemon.
# - generate_password function to avoid to put clear text passwords in hiera.
#   You can can use clear text passwords or use the __pwd__ syntax in hiera.
#
#
#==Hiera
#
#  # Optional. If not defined, the default value is either 'shinken_tag'
#  # or "shinken_$datacenter" if $datacenter is defined. The shinken server
#  # retrieves the exported files that have this tag and built its configuration
#  # to automatically check some puppet hosts.
#  shinken_tag: 'shinken_foo'
#
#
#  # These 2 entries below are optional. The values must be an array (empty
#  # array is possible but, in this case, you can remove the entry too).
#  shinken_node_templates:
#    - 'http_tpl'
#    - 'ftp_tpl'
#  shinken_node_properties:
#    _HTTP_WARN: '5'
#    _PROPERTY_NAME: 'property_value'
#
#  # Be careful, you must add too the hiera data from de snmp::snmpd class.
#  # You can see the doc header of this class.
#
#
class shinken::node {

  require 'repositories::shinken' # Add the shinken repository (made in CRDP).
  require 'snmp::snmpd'           # Install and configure snmpd.
  require 'shinken::node::params'

  $exported_dir         = $shinken::node::params::exported_dir
  $tag                  = $shinken::node::params::tag
  $additional_templates = $shinken::node::params::additional_templates
  $properties           = $shinken::node::params::properties

  # Updates will be manual.
  #exec { 'apt-get update for snmpd-extend':
  #  path    => '/bin:/usr/bin',
  #  command => 'apt-get update',
  #  returns => [ 0, 255 ],
  #  before  => Package['snmpd-extend'],
  #}

  package { 'snmpd-extend':
    #ensure => latest,
    ensure => present,
  }

  # The exported file collected by the shinken server.
  @@file { "${::hostname}_linux":
    path    => "$exported_dir/${::hostname}_linux.exp",
    content => template('shinken/node/hostname_linux.exp.erb'),
    tag     => "$tag",
  }

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

  # If these facters are not defined, it's probably a virtual machine
  # and, of course, no ipmi check in this case.
  if ($boardmanufacturer != undef) and ($boardproductname != undef) {

    # The exported file collected by the shinken server.
    # /!\ Currently not used. Just for information. /!\
    @@file { "${::hostname}_ipmi":
      path    => "$exported_dir/${::hostname}_ipmi.test",
      content => template('shinken/node/hostname_ipmi.exp.erb'),
      tag     => "$tag",
    }

    # check with "ipmi-sensors_tpl" only if the distribution is not
    # lenny or squeeze.
    if ($lsbdistcodename != 'lenny') and ($lsbdistcodename != 'squeeze') {
      $ipmi_sensors_tpl = 'true'
    }

  }


}



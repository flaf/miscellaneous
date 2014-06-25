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
#  # This entry is optional. The default value is 'false'. If the value
#  # is 'true', there is no IPMI check even if Puppet detects a motherboard
#  # in the host.
#  disable_ipmi_ckeck: 'true'
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
  $has_motherboard      = $shinken::node::params::has_motherboard
  $disable_ipmi_check   = $shinken::node::params::disable_ipmi_check
  $ipmi_sensors_tpl     = $shinken::node::params::ipmi_sensors_tpl

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

  if ($has_motherboard == 'true') {

    # The exported file collected by the shinken server.
    # /!\ Currently not used. Just for information. /!\
    @@file { "${::hostname}_ipmi":
      path    => "$exported_dir/${::hostname}_ipmi.test",
      content => template('shinken/node/hostname_ipmi.exp.erb'),
      tag     => "$tag",
    }

  }

}



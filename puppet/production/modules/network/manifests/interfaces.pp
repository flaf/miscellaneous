# Puppet class to primarily manage the /etc/network/interfaces file.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib.
#
# == Parameters
#
# *rename_interfaces*:
# Boolean to choose if you want to rename the interfaces. If
# true, the class will manage a udev rule with a file in the
# /etc/udev/rules.d/ directory. If true, to be effective,
# you must apply MAC addresses of the interfaces (see the
# "interfaces" parameter below) because the rule is a
# mapping "MAC address" to "interface name". The default
# value of this parameter is false.
#
# *restart_network*:
# Boolean to choose if you want to restart the network after
# the configuration update. In fact, the class doesn't
# really manage the /etc/network/interfaces file but the
# /etc/network/interfaces.puppet file. So, after the
# configuration update, if you don't restart the network,
# changes are not realized. if the parameter is set to true,
# after any change of the configuration, the whole network is
# restarted automatically and the change will be realized.
# Be careful, it could be dangerous to set this parameter to
# true for servers in production environment because the
# least configuration change will cause the restart of the
# whole network and if your new configuration is buggy...
# BANG!!! The default value of this parameter is false (more
# secure).
#
# *interfaces*:
# This parameter is mandatory and has no default value.
# This parameter is a hash with this form:
#
#  {
#   'eth0' => {
#               'macaddress' => '08:00:27:bc:cf:03',
#               'method'     => 'static',
#               'address'    => '172.31.20.6',
#               'netmask'    => '255.255.0.0',
#               'dns-search  => [ '@domain', 'toto.com', ],
#             },
#   'eth1' => {
#               'macaddress' => '08:00:27:bc:cf:04',
#               'method'     => 'dhcp',
#               'comment'    => 'Blabla',
#             },
#  }
#
# For each interface, the "method" property is mandatory.
# If the method is "static" the "address" and "netmask"
# properties are mandatory. The value of a property can
# be an array of strings. In this case, the value is
# updated to value.join(' '). If a value is a string
# with this form '@xxxx', it's automatically replaced by
# the @xxxx fact.
#
# There are some properties, the meta options, which are
# just put in comments. Here is the list of these meta options:
#
#  meta_options = [
#                  'macaddress',
#                  'network_name',
#                  'vlan_name',
#                  'vlan_id',
#                  'cidr_address',
#                  'comment',
#                 ]
#
#
# == Useful public functions
#
# === complete_ifaces_hash($ifaces, $inventoried_networks)
#
# The function returns an updated version of $ifaces with
# the informations inside $inventoried_networks which must
# contain the "cidr_address". Here is an example:
#
#  $interfaces = {
#   'eth0' => {
#               'macaddress'     => '08:00:27:bc:cf:03',
#               'method'         => 'static',
#               'address'        => '172.31.20.6/16',
#               'gateway'        => '<default>',
#               'dns-nameservers => '<default>',
#             },
#  }
#
#  $inventoried_networks = {
#    'private' => {
#                   'cidr_address'    => '172.31.0.0/16',
#                   'gateway'         => '172.31.0.1',
#                   'dns-nameservers' => [ '172.31.0.2', '172.31.0.3', ],
#                   'vlan_id'         => '0'
#                   'ntp_servers      => [ '172.31.0.1', ]
#                 }
#    'public'  => {
#                   'cidr_address'    => '192.168.0.0/24',
#                   'gateway'         => '192.168.0.1',
#                   'dns-nameservers' => [ '192.168.0.1', ],
#                   'vlan_id'         => '1'
#                   'ntp_servers      => [ '192.168.0.1', ]
#                 }
#
#  $new_ifaces = complete_ifaces_hash($ifaces, $inventoried_networks)
#
# In this example, the function use the CIDR address of eth0
# to find the matching network. Then, each value equal to
# '<default>' will be replaced by the value in the matching
# network. Note: with an interface with a CIDR address, the
# "netmask", "network" and "broadcast" properties will be
# automatically appended. It's possible to don't use a CIDR
# address for an interface, but if you want to help the
# function to find a matching network, you must use the
# "network_name" property in the interface ('public' or
# 'private' in the example above).
#
# === get_network_name($ipaddr, $netmask, $inventoried_networks)
#
# Returns the name of the network which matches with the
# $ipaddr and $netmask. Here is an example:
#
#  # Same value as the example above.
#  $inventoried_networks = ...
#
#  $network_name = get_network_name($ipaddr, $netmask, $inventoried_networks)
#
#  # Now, we can retrieve the list of the ntp servers
#  # in the current network.
#  $ntp_servers = $inventoried_networks[$network_name]
#
#
class network::interfaces (
  $rename_interfaces = false,
  $restart_network   = false,
  $interfaces,
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  # This options will be not used as stanza in the `interfaces` file,
  # but as comment for each interface.
  $meta_options = get_meta_options()

  ### Checking of parameters. ###
  unless is_bool($rename_interfaces) {
    fail("In the ${title} class, `rename_interfaces` parameter must be a boolean.")
  }

  unless is_bool($restart_network) {
    fail("In the ${title} class, `restart_network` parameter must be a boolean.")
  }

  unless is_hash($interfaces) {
    fail("In the ${title} class, `interfaces` parameter must be a hash.")
  }

  if empty($interfaces) {
    fail("In the ${tilte} class, `interfaces` parameter must not be empty.")
  }

  check_ifaces_hash($interfaces)

  # If a property is an array, the value is updated to v.join(' ').
  # Furthermore, if a value has this form '@xxxx', it's replaced
  # by the fact @xxxx. 
  $interfaces_flattened = flatten_ifaces_hash($interfaces)

  # To make uniform between Wheezy and Trusty.
  # Trusty uses resolvconf by default but not Wheezy.
  # And it's not recommended to remove resolvconf
  # in Trusty (if you do that, you will remove the
  # "ubuntu-minimal" package that is not recommended).
  if ! defined(Package['resolvconf']) {
    package { 'resolvconf':
      ensure => present,
    }
  }

  if $rename_interfaces {
    $content_rule = template('network/70-persistent-net.rules.erb')
    $replace_rule = true
  } else {
    $content_rule = "# Empty file created by Puppet because no interface renaming.\n"
    $replace_rule = false
  }

  file { '/etc/udev/rules.d/70-persistent-net.rules':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    replace => $replace_rule,
    content => $content_rule,
  }

  file { '/etc/network/interfaces.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('network/interfaces.puppet.erb'),
  }

  file { '/usr/local/sbin/network-restart':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0754',
    source => "puppet:///modules/network/network-restart",
  }

  if $restart_network {
    exec { 'network-restart':
      command     => '/usr/local/sbin/network-restart',
      user        => 'root',
      group       => 'root',
      refreshonly => true,
      require     => File['/usr/local/sbin/network-restart'],
      subscribe   => [
                       File['/etc/udev/rules.d/70-persistent-net.rules'],
                       File['/etc/network/interfaces.puppet'],
                     ],
    }
  }

}



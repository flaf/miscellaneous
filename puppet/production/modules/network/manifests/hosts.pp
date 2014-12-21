# Public class which allows to set the content of the /etc/hosts file.
#
# == Requirement/Dependencies
#
# Nothing.
#
# == Parameters
#
# *hosts_entries:*
# A hash which represents the hosts entries in /etc/hosts file.
# Default value is {} (empty hash) ie just the localhost
# entry and some IPv6 basic entries in the /etc/hosts file.
# The hash must either be empty or have this structure:
#
#  {
#   'entryA' => [ '<ip_addrA>', '<nameA1>', '<nameA2>', ... ],
#   'entryB' => [ '<ip_addrB>', '<nameB1>', '<nameB2>', ... ],
#   ...
#  }
#
# If there are duplicated hostnames, they are merged if they
# have the same IP address or the class fails if they have
# different IP addresses. In the arrays above, if a value
# has this form "@xxxx", it will be replaced by the value
# of the @xxxx variable.
#
# == Sample Usages
#
#  class { '::network::hosts':
#    hosts_entries => {
#                      'self' => [ '@ipaddress', '@fqdn', '@hostname' ],
#                     }
#  }
#
# or
#
#  class { '::network::hosts':
#    hosts_entries => {
#                      'self'          => [ '@ipaddress', '@fqdn', '@hostname' ],
#                      'cluster_node1' => [ '172.31.10.21', 'node1' ],
#                      'cluster_node2' => [ '172.31.10.22', 'node2' ],
#                      'cluster_node3' => [ '172.31.10.23', 'node3' ],
#                     }
#  }
#
# In this example above, if @hostname == 'node1' and if
# @ipaddress == '172.31.10.21', the 'self' entry and the
# 'cluster_node1' entry will be merged to only one entry
# in the /etc/hosts file.
#
class network::hosts (
  $hosts_entries = {},
  $imported_tag  = undef,
) {

  case $::lsbdistcodename {
    wheezy: {}
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  file { '/etc/hosts.puppet.d':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => true,
    purge   => true,
    force   => true,
    before  => File['/etc/hosts'],
  }

  file {'/etc/hosts.puppet.d/README':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "Directory managed by Puppet, don't touch it.\n",
  }

  if $imported_tag != undef {

    validate_string($imported_tag)

    File <<| tag == $imported_tag and tag == 'hosts_entry' |>> {
      require => File['/etc/hosts.puppet.d'],
      before  => File['/etc/hosts'],
    }

    $exported_hosts_entries = get_exported_hosts_entries()

  }

  if $exported_hosts_entries != undef {
    $global_hosts_entries = merge($hosts_entries, $exported_hosts_entries)
  } else {
    $global_hosts_entries = $hosts_entries
  }

  $hosts_entries_updated = update_hosts_entries($global_hosts_entries)

  file { '/etc/hosts':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('network/hosts.erb'),
  }

}



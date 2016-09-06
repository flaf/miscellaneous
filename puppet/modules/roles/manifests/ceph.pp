class roles::ceph {

  # We want to handle the class ::network::hosts as a specific case.
  class { '::roles::generic::params':
      # Add "::network::hosts" to the default excluded classes.
      excluded_classes => ::roles::data()['roles::generic::params::excluded_classes'] + [ '::network::hosts' ]
  }
  include '::roles::generic'


  # For the class ::network::hosts, we want to use the IP
  # addresses of the monitors.
  include '::ceph::params'

  $hosts_entries = $::ceph::params::cluster_conf['monitors'].reduce({}) |$memo, $entry| {
    [$host_name, $params] = $entry
    $memo + { $params['address'] => [ "${host_name}.${domain}", $host_name ] }
  }

  class { '::network::hosts::params': entries => $hosts_entries }
  include '::network::hosts'

  # For the ::ceph class, the ceph repository is required.
  include '::repository::ceph'

  class { '::ceph': require => Class['::repository::ceph'] }

  # We need to add 'ceph' as supplementary group of "snmp"
  # for the cluster nodes because "snmp" needs to be able to
  # read the osd/mon working directories.
  if $::ceph::params::nodetype == 'clusternode' {
    user { 'snmp':
      groups  => [ 'ceph' ],
      require => Class['::ceph'],
      notify  => Exec['restart-snmpd'],
    }

    # Yes, it's a dirty hack.
    exec { 'restart-snmpd':
      command     => 'service snmpd restart',
      path        => '/usr/sbin:/usr/bin:/sbin:/bin',
      user        => 'root',
      refreshonly => true,
    }
  }

}



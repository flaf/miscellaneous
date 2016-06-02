define ceph::radosgw (
  $cluster_name,
  $instance_name,
){

  file { "/var/lib/ceph/radosgw/${cluster_name}-${instance_name}":
    ensure  => directory,
    owner   => 'ceph',
    group   => 'ceph',
    mode    => '0755',
    recurse => false,
    purge   => false,
    force   => false,
    before  => Exec["radosgw-${cluster_name}-${instance_name}"],
  }

  # To have a start of radosgw at boot.
  file { "/var/lib/ceph/radosgw/${cluster_name}-${instance_name}/done":
    ensure  => present,
    owner   => 'ceph',
    group   => 'ceph',
    mode    => '0644',
    content => "# Managed by Puppet.\n",
    before  => Exec["radosgw-${cluster_name}-${instance_name}"],
  }

  exec { "radosgw-${cluster_name}-${instance_name}":
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    command => "service radosgw restart cluster=${cluster_name} id=${instance_name}",
    unless  => "service radosgw status cluster=${cluster_name} id=${instance_name}",
  }

}



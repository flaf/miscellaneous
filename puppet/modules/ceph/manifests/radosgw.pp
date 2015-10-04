#
# Private class.
#
define ceph::radosgw (
  $cluster_name = 'ceph',
  $account,
  $rgw_dns_name = undef,
){

  private("Sorry, ${title} is a private class.")

  case $::lsbdistcodename {
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  require '::ceph::radosgw::packages'

  file { "/var/lib/ceph/radosgw/${cluster_name}-${account}":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => false,
    purge   => false,
    force   => false,
  }

  # To have a start of radosgw at boot.
  file { "/var/lib/ceph/radosgw/${cluster_name}-${account}/done":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => "# Managed by Puppet.\n",
  }

  exec { "radosgw-${cluster_name}-${account}":
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    command => "service radosgw restart cluster=${cluster_name} id=${account}",
    unless  => "service radosgw status cluster=${cluster_name} id=${account}",
  }

}



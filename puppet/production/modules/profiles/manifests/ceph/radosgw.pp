class profiles::ceph::radosgw {

  require '::profiles::ceph::params'

  $ceph_conf    = $::profiles::ceph::params::ceph_conf
  $cluster_name = $::profiles::ceph::params::cluster_name
  $cluster_tag  = $::profiles::ceph::params::cluster_tag

  ::ceph::radosgw { $cluster_name:
    cluster_name => $cluster_name,
    magic_tag    => $cluster_tag,
  }

}



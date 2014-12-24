class roles::ceph_cluster {

  # inheritance from another roles.
  include '::roles::generic'

  include '::profiles::apt::ceph'
  include '::profiles::ceph::cluster'

}



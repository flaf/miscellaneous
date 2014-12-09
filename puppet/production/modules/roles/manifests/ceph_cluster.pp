class roles::ceph_cluster inherits ::roles::standard {

  include '::profiles::apt::ceph'
  include '::profiles::ceph::cluster'

}



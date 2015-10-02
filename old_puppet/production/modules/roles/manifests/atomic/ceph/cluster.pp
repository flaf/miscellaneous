class roles::atomic::ceph::cluster {

  include '::profiles::apt::ceph'
  include '::profiles::ceph::cluster'

}



class roles::atomic::ceph::radosgw {

  include '::profiles::apt::ceph'
  include '::profiles::apt::radosgw'
  include '::profiles::ceph::radosgw'

}



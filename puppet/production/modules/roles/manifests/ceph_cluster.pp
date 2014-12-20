class roles::ceph_cluster inherits ::roles::generic_without_hosts {

  include '::profiles::hosts::ceph'
  include '::profiles::apt::ceph'
  include '::profiles::ceph::cluster'

}



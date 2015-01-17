class roles::ceph::cluster {

  # inheritance from "generic" roles.
  include '::roles::generic'

  include '::roles::atomic::ceph::cluster'
  include '::roles::atomic::ceph::radosgw'

}


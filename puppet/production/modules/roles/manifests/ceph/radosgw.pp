class roles::ceph::radosgw {

  # inheritance from "generic" roles.
  include '::roles::generic'

  include '::roles::atomic::ceph::radosgw'

}



class roles::ceph::client {

  # inheritance from "generic" roles.
  include '::roles::generic'

  include '::roles::atomic::ceph::client'

}



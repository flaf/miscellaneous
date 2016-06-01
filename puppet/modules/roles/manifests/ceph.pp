class roles::ceph {

  include '::roles::generic'
  include '::repository::ceph'

  class { '::ceph':
    require => Class['::repository::ceph'],
  }

}



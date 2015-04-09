class profiles::apt::ceph ($stage = 'repositories', ) {

  class { '::repositories::ceph':
    version => 'hammer',
  }

}



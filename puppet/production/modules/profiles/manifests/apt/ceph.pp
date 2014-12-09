class profiles::apt::ceph ($stage = 'repository', ) {

  class { '::repository::ceph':
    version => 'firefly',
  }

}



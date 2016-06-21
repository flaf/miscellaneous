class roles::cargo {

  include '::roles::ceph'

  class { '::moo::cargo':
  }

}



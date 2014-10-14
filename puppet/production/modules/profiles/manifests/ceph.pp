class profiles::ceph {

  include apt

  apt::key { 'ceph':
    key        => '17ED316D',
    key_source => 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc',
  }




}


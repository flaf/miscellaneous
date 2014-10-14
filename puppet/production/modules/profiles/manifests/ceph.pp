class profiles::ceph {

  include apt

  apt::key { 'ceph':
    key        => '17ED316D',
    key_source => 'https://ceph.com/git/?p=ceph.git;a=blob_plain;f=keys/release.asc',
  }

  $ceph_release = "firefly"

  apt::source { 'ceph':
    location          => "http://ceph.com/debian-${ceph_release}/",
    release           => $::lsbdistcodename,
    repos             => 'main',
    include_src       => true
  }



}


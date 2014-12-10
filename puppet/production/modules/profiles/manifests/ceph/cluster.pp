class profiles::ceph::cluster {

  $ceph_conf = hiera_hash('ceph')
  $fsid      = $ceph_conf['fsid']

  # Test if the data has been well retrieved.
  if $fsid == undef {
    fail("Problem in class ${title}, `fsid` data not retrieved")
  }

  class { '::ceph':
    fsid => $fsid,
  }

}



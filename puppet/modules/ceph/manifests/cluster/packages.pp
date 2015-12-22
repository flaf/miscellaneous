class ceph::cluster::packages {

  require '::repository::ceph'

  # Deprecated: in fact with this kernel I had curious
  #             a behavior where the load average was
  #             blocked to ~ 0.5 even when the server
  #             was totally idle. Currenly, I prefer to
  #             keep the default kernel 3.13.
  #
  # With Trusty, it's better to use a 3.16 kernel.
  #
  # TODO: there is too the linux-image-generic-lts-vivid, ie a
  #       Linux kernel version 3.19. Maybe make some tests.
  #if $::lsbdistcodename == 'trusty' {
  #  ensure_packages(['linux-image-generic-lts-utopic'], { ensure => present, })
  #}

  $packages = [
                'ceph',
                'ceph-mds',
                'ceph-fuse', # To be able (sometime) to mount the cephfs in a cluster node.
                'xfsprogs',  # For xfs filesystem
                'procps',    # Used in the ceph_* scripts
              ]

  ensure_packages($packages, { ensure => present, })

}



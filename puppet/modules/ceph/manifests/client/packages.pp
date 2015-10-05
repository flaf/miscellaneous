#
# Private class.
#
class ceph::client::packages {

  require '::repository::ceph'

  $packages = [
                'ceph',           # Seems to be surer to install ceph in a
                                  # client because when you run a "ceph xxx"
                                  # command you have an error about the unfound
                                  # "ceph_argparse" module which is in the
                                  # "ceph" package (but the "ceph" command is
                                  # in the "ceph-common" package)..
                                  # In fact, it's probably a temporary bug:
                                  # https://github.com/ceph/ceph/pull/4517
                                  #
                'ceph-common',    # To use Rados block devices.
                'ceph-fs-common', # To mount cephfs via the kernel.
                'ceph-fuse',      # To mount cephfs via Fuse.
              ]

  ensure_packages($packages, { ensure => present, })

}



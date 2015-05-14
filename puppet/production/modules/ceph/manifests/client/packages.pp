#
# Private class.
#
class ceph::client::packages {

  private("Sorry, ${title} is a private class.")

  $packages = [
                'ceph',           # Seems to be surer to install ceph. For
                                  # instance, cinder can run this command
                                  # "ceph mon dump" which needs this package
                                  # (especially the ceph_argparse module).
                'ceph-common',    # To use Rados block devices.
                'ceph-fs-common', # To mount cephfs via the kernel.
                'ceph-fuse',      # To mount cephfs via Fuse.
              ]

  ensure_packages($packages, { ensure => present, })

}



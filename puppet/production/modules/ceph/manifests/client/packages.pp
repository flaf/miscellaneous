#
# Private class.
#
class ceph::client::packages {

  private("Sorry, ${title} is a private class.")

  $packages = [
                'ceph-common',    # To use Rados block devices.
                'ceph-fs-common', # To mount cephfs via the kernel.
                'ceph-fuse',      # To mount cephfs via Fuse.
              ]

  ensure_packages($packages, { ensure => present, })

}



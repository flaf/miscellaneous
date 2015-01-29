#
# Private class.
#
class ceph::cluster::packages {

  private("Sorry, ${title} is a private class.")

  $packages = [
                'ceph',
                'ceph-mds',
                'xfsprogs', # For xfs filesystem
                'procps',   # Used in the ceph_* scripts
              ]

  ensure_packages($packages, { ensure => present, })

}



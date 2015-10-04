#
# Private class.
#
class ceph::cluster::packages {

  private("Sorry, ${title} is a private class.")

  # With Trusty, it's better to use a 3.16 kernel.
  if $::lsbdistcodename == 'trusty' {
    ensure_packages(['linux-image-generic-lts-utopic'], { ensure => present, })
  }

  $packages = [
                'ceph',
                'ceph-mds',
                'xfsprogs', # For xfs filesystem
                'procps',   # Used in the ceph_* scripts
              ]

  ensure_packages($packages, { ensure => present, })

}



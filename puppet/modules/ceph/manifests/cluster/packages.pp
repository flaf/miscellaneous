#
# Private class.
#
class ceph::cluster::packages {

  require '::repository::ceph'

  # With Trusty, it's better to use a 3.16 kernel.
  #
  # TODO: there is too the linux-image-generic-lts-vivid, ie a
  #       Linux kernel version 3.19. Maybe make some tests.
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



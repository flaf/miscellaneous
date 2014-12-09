#
# Private class.
#
class ceph::packages {

  private("Sorry, ${title} is a private class.")

  if ! defined(Package['ceph']) {
    package { 'ceph':
      ensure => present,
    }
  }

  # XFS is the recommended filesystem for osd.
  if ! defined(Package['xfsprogs']) {
    package { 'xfsprogs':
      ensure => present,
    }
  }

}



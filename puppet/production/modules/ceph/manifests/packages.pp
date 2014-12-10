#
# Private class.
#
class ceph::packages {

  private("Sorry, ${title} is a private class.")

  ensure_packages(['ceph', 'xfsprogs', ], { ensure => present, })

}



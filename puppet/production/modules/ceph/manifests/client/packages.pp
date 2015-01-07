#
# Private class.
#
class ceph::client::packages {

  private("Sorry, ${title} is a private class.")

  $packages = [
                'ceph-common',
              ]

  ensure_packages($packages, { ensure => present, })

}



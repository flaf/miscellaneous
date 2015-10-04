#
# Private class.
#
class ceph::radosgw::packages {

  private("Sorry, ${title} is a private class.")

  $packages = [
                # We use civetweb.
                #'apache2',
                #'libapache2-mod-fastcgi',
                'ceph',
                'radosgw',
              ]

  ensure_packages($packages, { ensure => present, })

}


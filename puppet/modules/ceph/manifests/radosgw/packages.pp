class ceph::radosgw::packages {

  require '::repository::ceph'

  $packages = [
                # We use civetweb.
                #'apache2',
                #'libapache2-mod-fastcgi',
                'ceph',
                'radosgw',
              ]

  ensure_packages($packages, { ensure => present, })

}



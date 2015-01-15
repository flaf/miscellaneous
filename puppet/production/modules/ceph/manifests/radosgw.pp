# TODO: write the doc header.
#
define ceph::radosgw (
  $cluster_name = 'ceph',
  $magic_tag    = $cluster_name,
){

  case $::lsbdistcodename {
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  $packages = [
                'apache2',
                'libapache2-mod-fastcgi',
                'ceph',
                'radosgw',
              ]

  ensure_packages($packages, { ensure => present, })

  # In fact, a radosgw server is a ceph client.
  ::ceph::client { "${cluster_name}.client.${::hostname}":
    account      => $::hostname,
    cluster_name => $cluster_name,
    magic_tag    => $magic_tag,
  }

}



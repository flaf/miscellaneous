# TODO:
#
#   fstab:
#     id=cephfs,keyring=/etc/ceph/ceph.client.cephfs.keyring,client_mountpoint=/moodles /mnt/cephfs fuse.ceph noatime,defaults,_netdev 0 0
#
class moo::cargo (
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  require '::repository::docker'
  require '::moo::common'
  include '::moo::dockerapi'

  ensure_packages( [
                     'docker-engine',
                     'aufs-tools',
                   ],
                   {
                     ensure => present,
                   }
                 )

}



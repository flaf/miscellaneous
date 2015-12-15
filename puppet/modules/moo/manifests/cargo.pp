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

  ensure_packages( [
                     'docker-engine',
                     'aufs-tools',
                   ],
                   {
                     ensure => present,
                     before => Exec['pip-install-docker-py'],
                   }
                 )

  exec { 'pip-install-docker-py':
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    command => 'pip install docker-py',
    unless  => "pip list | grep '^docker-py'",
  }

}



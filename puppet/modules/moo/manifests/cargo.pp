class moo::cargo (
  String[1]           $ceph_account,
  String[1]           $ceph_client_mountpoint,
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

  file { '/mnt/shared':
    ensured => 'directory',
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }

  # Just shortcuts.
  $c      = $ceph_account
  $climnt = $ceph_client_mountpoint

  # With "present", the entry is added in /etc/fstab.
  # With "mounted", the entry is added in /etc/fstab and the
  # device is mounted immediately. But at this time, we can't
  # know if the ceph packages are already installed.
  mount { '/mnt/shared':
    #ensure   => mounted,
    ensure   => present,
    device   => "id=$c,keyring=/etc/ceph/ceph.client.$c.keyring,client_mountpoint=${climnt}",
    fstype   => 'fuse.ceph',
    remounts => false,
    options  => 'noatime,defaults,_netdev',
    require  => File['/mnt/shared'],
  }

}



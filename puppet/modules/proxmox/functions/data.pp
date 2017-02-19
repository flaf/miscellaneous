function proxmox::data {

  {
    proxmox::params::zfs_arc_max             => undef,
    proxmox::params::swappiness              => undef,
    proxmox::params::admin_users             => [],
    proxmox::params::apt_nosub_url           => 'http://download.proxmox.com/debian',
    proxmox::params::apt_nosub_component     => 'pve-no-subscription',
    proxmox::params::supported_distributions => [ 'jessie' ],
  }

}



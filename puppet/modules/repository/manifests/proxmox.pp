class repository::proxmox {

  include '::repository::proxmox::params'

  [
   $url,
   $supported_distributions,
  ] = Class['::repository::proxmox::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # Proxmox Release Key (proxmox-ve-release-4.x.gpg).
  $key1     = 'BE25 7BAA 5D40 6D01 157D  323E C23A C7F4 9887 F95A'
  # Proxmox Virtual Environment 5.x Release Key (proxmox-ve-release-5.x.gpg).
  $key2     = '359E 9596 5E2C 3D64 3159  CD30 0D9A 1950 E2EF 0603'
  $codename = $::facts['lsbdistcodename']
  $comment  = "Proxmox ${codename} Repository."

  repository::aptkey { 'proxmox-key1':
    id => $key1,
  }

  repository::aptkey { 'proxmox-key2':
    id => $key2,
  }

  repository::sourceslist { "pve-no-subscription":
    comment    => $comment,
    location   => "${url}",
    release    => $codename,
    components => [ 'pve-no-subscription' ],
    src        => false,
    require    => [
                   Repository::Aptkey['proxmox-key1'],
                   Repository::Aptkey['proxmox-key2'],
                  ],
  }

}



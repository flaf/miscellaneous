class repository::proxmox (
  String[1] $stage = 'repository',
) {

  include '::repository::proxmox::params'

  $url = $::repository::proxmox::params::url

  $key      = 'BE257BAA5D406D01157D323EC23AC7F49887F95A'
  $codename = $::facts['lsbdistcodename']
  $comment  = "Proxmox ${codename} Repository."

  # Use hkp on port 80 to avoid problem with firewalls etc.
  apt::key { 'proxmox':
    id     => $key,
    server => 'hkp://keyserver.ubuntu.com:80',
  }

  apt::source { "pve-enterprise":
    comment  => $comment,
    location => "${url}",
    release  => $codename,
    repos    => 'pve-enterprise',
    include  => { 'src' => false, 'deb' => true },
    require  => Apt::Key['proxmox'],
  }

}



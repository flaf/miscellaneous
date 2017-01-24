class roles::proxmox {

  unless $::is_proxmox {
    @("END"/L$).fail
      ${title}: sorry you can apply this class only to a Proxmox \
      server and it is not the case of the current host.
      |- END
  }

  # At each boot, the PermitRootLogin is automatically set
  # to yes with a Proxmox server (probably necessary with
  # Proxmoxs in "cluster" mode). So, we don't manage this
  # parameter.
  class { '::roles::generic':
    excluded_classes => [ '::network::hosts', '::basic_ssh::server' ]
  }

  # Normally useless because already present after the OS
  # installation.
  ensure_packages(['openssh-server', ], { ensure => present, })

  include '::proxmox'

}



class roles::proxmox {

  unless $::is_proxmox {
    @("END"/L$).fail
      ${title}: sorry you can apply this class only to a Proxmox \
      server and it is not the case of the current host.
      |- END
  }

  class { '::roles::generic':
    excluded_classes => [ '::network::hosts' ]
  }

}



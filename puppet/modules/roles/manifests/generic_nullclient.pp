class roles::generic_nullclient {

  include '::network::params'

  $interfaces         = $::network::params::interfaces
  $inventory_networks = $::network::params::inventory_networks
  $admin_email        = ::network::get_param($interfaces, $inventory_networks, 'admin_email')
  $smtp_relay         = $::network::params::smtp_relay
  $smtp_port          = $::network::params::smtp_port

  unless $admin_email =~ NotUndef {
    @("END"/L$).fail
      ${title}: sorry the variable \$admin_email is undefined.
      |- END
  }

  unless $smtp_relay =~ NotUndef {
    @("END"/L$).fail
      ${title}: sorry the variable \$smtp_relay is undefined.
      |- END
  }

  unless $smtp_port =~ NotUndef {
    @("END"/L$).fail
      ${title}: sorry the variable \$smtp_port is undefined.
      |- END
  }

  class { '::eximnullclient::params':
    dc_smarthost         => [ { 'address' => $smtp_relay, 'port' => $smtp_port } ],
    redirect_local_mails => $admin_email,
    before               => Class['::roles::generic'],
  }

  class { '::roles::generic::params':
    # We want to remove "::eximnullclient" from the excluded classes.
    excluded_classes => ::roles::data()['roles::generic::params::excluded_classes'] - [ '::eximnullclient' ],
    before           => Class['::roles::generic'],
  }

  include '::roles::generic'

}


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

  include '::unix_accounts::params'

  # To keep only sudo users and root.
  $admin_users = $::unix_accounts::params::users.filter |$username, $settings| {

    $is_sudo = ('is_sudo' in $settings) and $settings['is_sudo']

    ($username == 'root') or $is_sudo

  }.reduce([]) |$memo, $entry| {

    [ $username, $settings ] = $entry

    case 'email' in $settings {
      true: {
        $new_user = { 'username' => $username, 'email' => $settings['email'], }
      }
      false: {
        $new_user = { 'username' => $username, }
      }
    }

    $memo + [ $new_user ]
  }

  # All Unix accounts which are sudo and root are "admin" in
  # the Proxmox WebUI.
  class { '::proxmox::params':
    admin_users => $admin_users,
  }
  include '::proxmox'

  # Add a checkpoint.
  $fqdn                     = $::facts['networking']['fqdn']
  $proxmox_checkpoint_title = "${fqdn} from ${title}"
  $custom_variables         = [
    {
      'varname' => '_https_pages',
      'value'   => {
        'webUI-proxmox' => ["${fqdn}:8006}", 'PVE.UserName'],
      },
    },
  ]

  monitoring::host::checkpoint {$proxmox_checkpoint_title:
    templates        => ['https_tpl'],
    custom_variables => $custom_variables,
  }

}



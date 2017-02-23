class proxmox {

  include '::proxmox::params'

  [
    $zfs_arc_max_value,
    $ensure_zfs_conf,
    $swappiness_value,
    $ensure_swappiness_conf,
    $admin_users,
    $apt_nosub_url,
    $apt_nosub_component,
    $supported_distributions,
  ] = Class['::proxmox::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ### Management of the script to add/remove the
  ### no-subscription APT repository.

  file { '/usr/local/sbin/pve-nosub-apt.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => epp('proxmox/pve-nosub-apt.puppet.epp',
                   {
                     'url'          => $apt_nosub_url,
                     'distribution' => $::facts["os"]["distro"]["codename"],
                     'component'    => $apt_nosub_component,
                   },
                  ),
  }


  ### Management of /etc/pve/user.cfg etc. ###

  case $admin_users.empty {
    true: {
      $ensure_user_cfg  = 'absent'
      $content_user_cfg = undef
    }
    false: {
      $ensure_user_cfg  = 'present'
      $content_user_cfg = epp('proxmox/user.cfg.epp', {'admin_users' => $admin_users,})
    }
  }

  # With Proxmox, /etc/pve/ is a fuse filesystem and
  # chmod/chown just don't work in /etc/pve/ and trigger
  # errors during a puppet run when puppet manages a file in
  # /etc/pve/. So, instead to manage a file /etc/pve/user.cfg,
  # we will manage the file /etc/pve.puppet/user.cfg in a
  # special directory /etc/pve.puppet/.
  file { '/etc/pve.puppet':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    recurse => true,
    purge   => true,
    force   => true,
  }

  $user_cfg        = '/etc/pve/user.cfg'
  $user_cfg_puppet = '/etc/pve.puppet/user.cfg'

  file { $user_cfg_puppet:
    ensure  => $ensure_user_cfg,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $content_user_cfg,
    notify  => Exec['rewrite-pve-user-cfg'],
  }

  file { '/usr/local/sbin/rewrite-pve-user-cfg.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => epp('proxmox/rewrite-pve-user-cfg.puppet.epp',
                   {
                     'user_cfg'        => $user_cfg,
                     'user_cfg_puppet' => $user_cfg_puppet,
                   },
                  ),
  }

  exec { 'rewrite-pve-user-cfg':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => '/usr/local/sbin/rewrite-pve-user-cfg.puppet',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    require     => File['/usr/local/sbin/rewrite-pve-user-cfg.puppet'],
  }

  ### Management of /etc/issue (cosmetic). ###

  $myfqdn = $::facts['networking']['fqdn']

  file_line { 'edit-https-url-in-etc-issue':
    path  => '/etc/issue',
    line  => "  https://${myfqdn}:8006/  # Edited by Puppet.",
    match => '^[[:space:]]*https://.*$',
  }

  ### Management of zfs_arc_max and swappiness. ###

  $content_zfs_conf = @("END")
    ### This file is managed by Puppet, don't edit it. ###
    options zfs zfs_arc_max=${zfs_arc_max_value}
    | END

  file { '/etc/modprobe.d/zfs.conf':
    ensure  => $ensure_zfs_conf,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content_zfs_conf,
    notify  => Exec['proxmox-update-initramfs'],
  }

  exec { 'proxmox-update-initramfs':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'update-initramfs -u',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
  }

  $content_swappiness_conf = @("END")
    ### This file is managed by Puppet, don't edit it. ###
    vm.swappiness=${swappiness_value}
    | END

  file { '/etc/sysctl.d/swappiness.conf':
    ensure  => $ensure_swappiness_conf,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $content_swappiness_conf,
    notify  => Exec['proxmox-update-swappiness'],
  }

  $update_swappiness = $swappiness_value ? {
    # Normally the default value of swappiness is 60 but it
    # can change in function of the Linux version.
    #Undef   => 'sysctl -w "vm.swappiness=60"',
    #
    Undef   => 'echo Need to reboot',
    default => 'sysctl --load=/etc/sysctl.d/swappiness.conf'
  }

  exec { 'proxmox-update-swappiness':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => $update_swappiness,
    user        => 'root',
    group       => 'root',
    refreshonly => true,
  }

}



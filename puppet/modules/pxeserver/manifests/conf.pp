class pxeserver::conf {

  $distribs_provided = {
    'trusty' => {
      'family'       => 'ubuntu',
      'boot_options' => 'locale=en_US.UTF-8 keymap=fr',
    },
    'jessie' => {
      'family'       => 'debian',
      'boot_options' => 'locale=en_US.UTF-8 keyboard-configuration/xkb-keymap=fr(latin9)',
    },
  }

  $pxe_entries = {

    'trusty-partial-preseed-with-puppet' => {
      'distrib'    => 'trusty',
      'menu_label' => '[trusty] partial preseed with puppet installed',
      'text_help'  => @(END),
        Semi manual installation of Ubuntu Trusty.
        Manual handling for:
          - network configuration,
          - disk partioning,
          - Grub installation.
        During the choice of the hostname, put the fqdn directly
        (or just a short hostname if the DHCP sends already a correct domain).
        |- END
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
      'install_puppet'             => true,
      'permitrootlogin_ssh'        => true,
    },

    'jessie-partial-preseed-with-puppet' => {
      'distrib'    => 'jessie',
      'menu_label' => '[jessie] partial preseed with puppet installed',
      'text_help'  => @(END),
        Semi manual installation of Debian Jessie.
        Manual handling for:
          - network configuration,
          - disk partioning,
          - Grub installation.
        |- END
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
      'install_puppet'             => true,
      'permitrootlogin_ssh'        => true,
    },

    'jessie-elea-moosql' => {
      'distrib'    => 'jessie',
      'menu_label' => '[jessie] install Elea moosql servers',
      'text_help'  => @(END),
        1. Network configuration (interface, hostname)
        2. Partitioning (do not format the partitions, it is already done)
         RAID1 dev#0:    fs => EXT4, mntpt => /,              mntopt => noatime
         LV tmp:         fs => EXT4, mntpt => /tmp,           mntopt => noatime
         LV backups:     fs => XFS,  mntpt => /backups,       mntopt => noatime
         LV varlogmysql: fs => XFS,  mntpt => /var/log/mysql, mntopt => noatime
         LV varlibmysql: fs => EXT4, mntpt => /var/lib/mysql, mntopt => noatime
        |- END
      'install_puppet'      => true,
      'permitrootlogin_ssh' => true,
    },

  }

}



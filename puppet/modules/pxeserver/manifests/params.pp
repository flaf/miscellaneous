class pxeserver::params (
  Optional[ Hash[String[1], Pxeserver::Dhcpconf, 1] ] $dhcp_confs,
  Array[String[1]]                                    $no_dhcp_interface,
  String                                              $apt_proxy,
  Hash[String[1], Array[String[1], 2, 2]]             $ip_reservations,
  Optional[ String[1] ]                               $puppet_collection,
  Optional[ String[1] ]                               $pinning_puppet_version,
  Optional[ String[1] ]                               $puppet_server,
  Optional[ String[1] ]                               $puppet_ca_server,
  Optional[ String[1] ]                               $puppet_apt_url,
  Optional[ String[1] ]                               $puppet_apt_key,
  Array[String[1], 1]                                 $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # Some variables for common help messages.
  $semi_manual_install_ubuntu = @(END)
    Semi manual installation of Ubuntu __DISTRIB__.
    Manual handling for:
      - network configuration,
      - disk partioning,
      - Grub installation.
    During the choice of the hostname, put the fqdn directly
    (or just a short hostname if the DHCP sends already a correct domain).
    |- END

  $semi_manual_install_debian = @(END)
    Semi manual installation of Debian __DISTRIB__.
    Manual handling for:
      - network configuration,
      - disk partioning,
      - Grub installation.
    |- END

  $all_in_sda_install_ubuntu = @(END)
    Semi manual installation of Ubuntu __DISTRIB__.
    Manual handling for network configuration.
    During the choice of the hostname, put the fqdn directly
    (or just a short hostname if the DHCP sends already a correct domain).
    |- END

  $all_in_sda_install_debian = @(END)
    Semi manual installation of Debian __DISTRIB__.
    Manual handling for network configuration.
    |- END

  $semi_manual_install_trusty = $semi_manual_install_ubuntu.regsubst('__DISTRIB__', 'Trusty')
  $semi_manual_install_xenial = $semi_manual_install_ubuntu.regsubst('__DISTRIB__', 'Xenial')
  $semi_manual_install_jessie = $semi_manual_install_debian.regsubst('__DISTRIB__', 'Jessie')
  $all_in_sda_install_trusty  = $all_in_sda_install_ubuntu.regsubst('__DISTRIB__', 'Trusty')
  $all_in_sda_install_xenial  = $all_in_sda_install_ubuntu.regsubst('__DISTRIB__', 'Xenial')
  $all_in_sda_install_jessie  = $all_in_sda_install_debian.regsubst('__DISTRIB__', 'Jessie')

  $pxe_entries = {

    'trusty-partial-preseed-without-puppet' => {
      'insert_begin'               => 'MENU BEGIN Partial preseed without puppet installed',
      'distrib'                    => 'trusty',
      'menu_label'                 => '[trusty] Partial preseed without puppet installed',
      'text_help'                  => $semi_manual_install_trusty,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
      'install_puppet'             => false,
    },

    'xenial-partial-preseed-without-puppet' => {
      'distrib'                    => 'xenial',
      'menu_label'                 => '[xenial] Partial preseed without puppet installed',
      'text_help'                  => $semi_manual_install_xenial,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
      'install_puppet'             => false,
    },

    'jessie-partial-preseed-without-puppet' => {
      'distrib'                    => 'jessie',
      'menu_label'                 => '[jessie] Partial preseed without puppet installed',
      'text_help'                  => $semi_manual_install_jessie,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
      'install_puppet'             => false,
      'insert_end'                 => 'MENU END',
    },

    'trusty-partial-preseed-with-puppet' => {
      'insert_begin'               => 'MENU BEGIN Partial preseed with puppet installed',
      'distrib'                    => 'trusty',
      'menu_label'                 => '[trusty] Partial preseed with puppet installed',
      'text_help'                  => $semi_manual_install_trusty,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
    },

    'xenial-partial-preseed-with-puppet' => {
      'distrib'                    => 'xenial',
      'menu_label'                 => '[xenial] Partial preseed with puppet installed',
      'text_help'                  => $semi_manual_install_xenial,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
    },

    'jessie-partial-preseed-with-puppet' => {
      'distrib'                    => 'jessie',
      'menu_label'                 => '[jessie] Partial preseed with puppet installed',
      'text_help'                  => $semi_manual_install_jessie,
      'apt_proxy'                  => $apt_proxy,
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
      'insert_end'                 => 'MENU END',
    },

    'trusty-all-in-sda-preseed-without-puppet' => {
      'insert_begin'               => 'MENU BEGIN All in /dev/sda without puppet installed',
      'distrib'                    => 'trusty',
      'menu_label'                 => '[trusty] All in /dev/sda without puppet installed',
      'text_help'                  => $all_in_sda_install_trusty,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => '/dev/sda',
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
    },

    'xenial-all-in-sda-preseed-without-puppet' => {
      'distrib'                    => 'xenial',
      'menu_label'                 => '[xenial] All in /dev/sda without puppet installed',
      'text_help'                  => $all_in_sda_install_xenial,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => '/dev/sda',
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
    },

    'jessie-all-in-sda-preseed-without-puppet' => {
      'distrib'                    => 'jessie',
      'menu_label'                 => '[jessie] All in /dev/sda without puppet installed',
      'text_help'                  => $all_in_sda_install_jessie,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => '/dev/sda',
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
      'insert_end'                 => 'MENU END',
    },

    'trusty-all-in-sda-preseed-with-puppet' => {
      'insert_begin'               => 'MENU BEGIN All in /dev/sda with puppet installed',
      'distrib'                    => 'trusty',
      'menu_label'                 => '[trusty] All in /dev/sda with puppet installed',
      'text_help'                  => $all_in_sda_install_trusty,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => '/dev/sda',
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
    },

    'xenial-all-in-sda-preseed-with-puppet' => {
      'distrib'                    => 'xenial',
      'menu_label'                 => '[xenial] All in /dev/sda with puppet installed',
      'text_help'                  => $all_in_sda_install_xenial,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => '/dev/sda',
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
    },

    'jessie-all-in-sda-preseed-with-puppet' => {
      'distrib'                    => 'jessie',
      'menu_label'                 => '[jessie] All in /dev/sda with puppet installed',
      'text_help'                  => $all_in_sda_install_jessie,
      'apt_proxy'                  => $apt_proxy,
      'partman_auto_disk'          => '/dev/sda',
      'skip_boot_loader'           => false,
      'partman_early_command_file' => 'nothing',
      'late_command_file'          => 'nothing',
      'insert_end'                 => 'MENU END',
    },

    ###################################
    ### Very specific installations ###
    ###################################

    'jessie-elea-moosql' => {
      'insert_begin' => 'MENU BEGIN Specific installations',
      'distrib'      => 'jessie',
      'menu_label'   => '[jessie] Install Elea moosql (Supermicro - Transtec)',
      'apt_proxy'    => $apt_proxy,
      'text_help'    => @(END),
        1. Network configuration (interface, hostname)
        2. Partitioning (do not format the partitions, it is already done)
         RAID1 dev#0:    fs => EXT4, mntpt => /,              mntopt => noatime
         LV tmp:         fs => EXT4, mntpt => /tmp,           mntopt => noatime
         LV backups:     fs => XFS,  mntpt => /backups,       mntopt => noatime
         LV varlogmysql: fs => XFS,  mntpt => /var/log/mysql, mntopt => noatime
         LV varlibmysql: fs => EXT4, mntpt => /var/lib/mysql, mntopt => noatime
        |- END
    },

    'trusty-elea-cargo' => {
      'distrib'    => 'trusty',
      'menu_label' => '[trusty] Install Elea cargo (HP - Antemeta)',
      'apt_proxy'  => $apt_proxy,
      'text_help'  => @(END),
        WARNING: For the hostname question, put the FQDN of the host
        unless the DHCP server already sends the good domain name.
        Manual handling
          1. Network configuration
          2. Partitioning: just set a) /dev/sdb3 => EXT4 / noatime
             and b) /dev/sdb5 => XFS  /backups noatime.
             (do not format the partition, it is already done)
        |- END
    },

    'trusty-ceph-dc2' => {
      'distrib'    => 'trusty',
      'menu_label' => '[trusty] Install Ceph (Supermicro - ASInfo)',
      'apt_proxy'  => $apt_proxy,
      'insert_end' => 'MENU END',
      'text_help'  => @(END),
        WARNING: For the hostname question, put the FQDN of the host
        unless the DHCP server already sends the good domain name.
        Manual handling
          1. Network configuration
          2. Partitioning: just set the /dev/sda3 device to
             filesytem => EXT4, mountpoint => /, mount options => noatime
             (do not format the partition, it is already done)
        |- END
    },

  }

  $distribs_provided = {
    ### Ubuntu LTS ###
    'trusty' => {
      'family'       => 'ubuntu',
      'boot_options' => 'locale=en_US.UTF-8 keymap=fr',
    },
    'xenial' => {
      'family'       => 'ubuntu',
      'boot_options' => 'locale=en_US.UTF-8 keymap=fr',
    },
    ### Debian ###
    'jessie' => {
      'family'       => 'debian',
      'boot_options' => 'locale=en_US.UTF-8 keyboard-configuration/xkb-keymap=fr(latin9)',
    },
  }

}



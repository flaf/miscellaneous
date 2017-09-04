define unix_accounts::user (
  Unix_accounts::Login        $login = $title,
  Unix_accounts::UserSettings $settings,
) {


  $default_settings   = ::unix_accounts::defaults(
                          $login,
                          $settings['ensure'],
                        )
  $settings_completed = $default_settings + $settings

  # Tag: USER_PARAMS
  $password             = $settings_completed['password']
  $ensure               = $settings_completed['ensure']
  $uid                  = $settings_completed['uid']
  $gid                  = $settings_completed['gid']
  $home                 = $settings_completed['home']
  $home_unix_rights     = $settings_completed['home_unix_rights']
  $managehome           = $settings_completed['managehome']
  $shell                = $settings_completed['shell']
  $fqdn_in_prompt       = $settings_completed['fqdn_in_prompt']
  $supplementary_groups = $settings_completed['supplementary_groups']
  $membership           = $settings_completed['membership']
  $is_sudo              = $settings_completed['is_sudo']
  $ssh_authorized_keys  = $settings_completed['ssh_authorized_keys']
  $purge_ssh_keys       = $settings_completed['purge_ssh_keys']
  $ssh_public_keys      = $settings_completed['ssh_public_keys']
  $email                = $settings_completed['email']

  # An explicit name of the resource for error messages.
  $rsrc_name = "Unix_accounts::User['${title}']"

  if $login == 'root' and $ensure != 'present' {
    @("END"/L$).fail
      ${rsrc_name}: the `root` account has the `ensure` \
      parameter not set to 'present' which is forbidden \
      for this account.
      |- END
  }

  if $login == 'root' and $home != '/root' {
    @("END"/L$).fail
      ${rsrc_name}: the `root` account has the `home` \
      parameter not set to '/root' which is forbidden \
      for this account.
      |- END
  }

  if $login in $supplementary_groups {
    @("END"/L$).fail
      ${rsrc_name}: `$login` account has the `supplementary_groups` which \
      contains the group `$login`. It is forbidden because `$login` is \
      automatically the primary group of the account. You must remove \
      the group `$login` from the supplementary groups.
      |- END
  }

  if ( 'sudo' in $supplementary_groups ) and !$is_sudo {
    @("END"/L$).fail
      ${rsrc_name}: `$login` account has the `supplementary_groups` which \
      contains the group `sudo` but its parameter `is_sudo` set to false. \
      It is inconsistent.
      |- END
  }

  if $ensure == 'ignore' {
    # It's simple, in this case, the resource does nothing.
    return()
  }




  ###################################
  ### The Unix account management ###
  ###################################
  #
  # .bashrc.puppet, .vimrc and ssh_authorized_ keys are not
  # handled in this part. Furthermore, root is not concerned
  # by this part.
  #
  #
  # The root Unix account is not handled by this user
  # defined resource in this part. The root Unix account is
  # a specific case.
  if $login != 'root' {

    ensure_packages(['sudo'], {ensure => present})

    $suppl_groups = case $is_sudo {
      true:    { unique(['sudo'] + $supplementary_groups) }
      default: { unique($supplementary_groups)            }
    }

    # Tag: USER_PARAMS
    # This part doesn't contain all the user parameters.
    user { $login:
      password       => $password,
      name           => $login,
      ensure         => $ensure,
      uid            => $uid,
      gid            => $gid,
      home           => $home,
      managehome     => $managehome,
      shell          => $shell,
      groups         => $suppl_groups,
      membership     => $membership,
      purge_ssh_keys => $purge_ssh_keys,
      expiry         => absent,
      system         => false,
    }

    # Set the Unix rights of the home directory.
    if $ensure == 'present' {
      file { "${home}":
        ensure  => directory,
        owner   => $login,
        group   => $login,
        mode    => $home_unix_rights,
        require => User[$login],
      }
    }

    # Management of the sudo file of $login.
    $ensure_sudo_file = case [$ensure, $is_sudo] {
      ['present', true   ]: { 'present' }
      [default,   default]: { 'absent'  }
    }

    file { "/etc/sudoers.d/${login}":
      ensure  => $ensure_sudo_file,
      owner   => 'root',
      group   => 'root',
      mode    => '0440',
      content => epp('unix_accounts/sudofile.epp',
                     {'user' => $login,}
                 ),
      require => [ Package['sudo'], User[$login] ],
    }

  }
  ##########################################
  ### End of the Unix account management ###
  ##########################################




  ########################################
  ### Management of .bashrc and .vimrc ###
  ########################################
  #
  # This part concerns the root Unix account too.
  #
  if $ensure == 'present' {

    file_line { "edit-bashrc-of-${login}":
      path    => "${home}/.bashrc",
      line    => ". ${home}/.bashrc.puppet # Edited by Puppet.",
      require => User[$login],
    }

    file_line { "edit-bashrc-of-${login}-HISTFILESIZE":
      path    => "${home}/.bashrc",
      line    => "#HISTFILESIZE=2000 # Edited by Puppet.",
      match   => '#?[[:space:]]*HISTFILESIZE=.*$',
      require => User[$login],
    }

    $is_sudo_or_root = $login ? {
      'root'  => true,
      default => $is_sudo,
    }

    file { "${home}/.bashrc.puppet":
      owner   => $login,
      group   => $login,
      mode    => '0644',
      require => User[$login],
      content => epp('unix_accounts/bashrc.puppet.epp',
                     {
                       'fqdn_in_prompt'  => $fqdn_in_prompt,
                       'is_sudo_or_root' => $is_sudo_or_root,
                     }
                 ),
    }

    file { "${home}/.vimrc":
      owner   => $login,
      group   => $login,
      mode    => '0644',
      require => User[$login],
      source  => 'puppet:///modules/unix_accounts/vimrc',
    }

  }
  ##################################################
  ### End of th management of .bashrc and .vimrc ###
  ##################################################




  #############################################
  ### Management of the ssh_authorized_keys ###
  #############################################
  #
  # Only if the user has $ensure == 'present'.
  #
  if $ensure == 'present' {

    $ssh_authorized_keys.each |$keyname| {

      unless $keyname in $ssh_public_keys {
        @("END"/L$).fail
          ${rsrc_name}: `$login` account should have the `$keyname` ssh key \
          as authorized key but this key does not exist in the list of ssh \
          public keys.
          |- END
      }

      $type = case 'type' in $ssh_public_keys[$keyname] {
        true:    { $ssh_public_keys[$keyname]['type'] }
        default: { 'ssh-rsa'                          }
      }

      # Just to allow ssh_public_keys in hiera in multiple
      # lines with ">".
      $key = $ssh_public_keys[$keyname]['keyvalue'].regsubst(' ', '', 'G').strip

      ssh_authorized_key { "${login}~${keyname}":
        user => $login,
        type => $type,
        key  => $key,
      }

    }

  }
  ########################################################
  ### End of the management of the ssh_authorized_keys ###
  ########################################################

}



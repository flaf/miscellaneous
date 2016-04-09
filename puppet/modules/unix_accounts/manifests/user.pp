# Tag: USER_PARAMS
#
define unix_accounts::user (
  String[1]                             $login = $title,
  String[1]                             $password,
  Unix_accounts::Ensure                 $ensure = ::unix_accounts::defaults($login)['ensure'],
  Optional[Integer]                     $uid = ::unix_accounts::defaults($login)['uid'],
  Optional[Variant[Integer, String[1]]] $gid = ::unix_accounts::defaults($login)['gid'],
  String[1]                             $home = ::unix_accounts::defaults($login)['home'],
  Unix_accounts::Unixrights             $home_unix_rights = ::unix_accounts::defaults($login)['home_unix_rights'],
  Boolean                               $managehome = ::unix_accounts::defaults($login)['managehome'],
  String[1]                             $shell = ::unix_accounts::defaults($login)['shell'],
  Boolean                               $fqdn_in_prompt = ::unix_accounts::defaults($login)['fqdn_in_prompt'],
  Array[String[1]]                      $supplementary_groups = ::unix_accounts::defaults($login)['supplementary_groups'],
  Unix_accounts::Membership             $membership = ::unix_accounts::defaults($login)['membership'],
  Boolean                               $is_sudo = ::unix_accounts::defaults($login)['is_sudo'],
  Array[String[1]]                      $ssh_authorized_keys = ::unix_accounts::defaults($login)['ssh_authorized_keys'],
  Boolean                               $purge_ssh_keys = ::unix_accounts::defaults($login)['purge_ssh_keys'],
  Unix_accounts::Ssh_public_keys        $ssh_public_keys = ::unix_accounts::defaults($login)['ssh_public_keys'],
) {

  # An explicit name of the resource for error messages.
  $rsrc_name = "Unix_accounts::User['${title}']"

  if $login == 'root' and $ensure != 'present' {
    @("END").regsubst('\n', ' ', 'G').fail
      ${rsrc_name}: the `root` account has the `ensure`
      parameter not set to 'present' which is forbidden
      for this account.
      |- END
  }

  if $login == 'root' and $home != '/root' {
    @("END").regsubst('\n', ' ', 'G').fail
      ${rsrc_name}: the `root` account has the `home`
      parameter not set to '/root' which is forbidden
      for this account.
      |- END
  }




  ###################################
  ### The Unix account management ###
  ###################################
  #
  # .bashrc.puppet, .vimrc dans ssh authorized keys are not
  # managed in this part. Futhermore, root is not concerned
  # by this part.
  #
  if $ensure != 'ignore' {

    if $login in $supplementary_groups {
      @("END").regsubst('\n', ' ', 'G').fail
        ${rsrc_name}: `$login` account has the `supplementary_groups` which
        contains the group `$login`. It is forbidden because `$login` is
        automatically the primary group of the account. You must remove
        the group `$login` from the supplementary groups.
        |- END
    }

    if ( 'sudo' in $supplementary_groups ) and !$is_sudo {
      @("END").regsubst('\n', ' ', 'G').fail
        ${rsrc_name}: `$login` account has the `supplementary_groups` which
        contains the group `sudo` but its parameter `is_sudo` set to false.
        It is inconsistent.
        |- END
    }

    # The root Unix account is not handled by this user
    # defined resource. The root Unix account is a specific
    # case.
    if $login != 'root' {

      ensure_packages( ['sudo'], { ensure => present } )

      case $is_sudo {
        true:    { $suppl_groups = unique(['sudo'] + $supplementary_groups) }
        default: { $suppl_groups = unique($supplementary_groups)            }
      }

      # Tag: USER_PARAMS (not contains all the user parameters)
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
      case [ $ensure, $is_sudo ] {
        [ 'present', true ]:    { $ensure_sudo_file = 'present' }
        [ default,   default ]: { $ensure_sudo_file = 'absent'  }
      }

      file { "/etc/sudoers.d/${login}":
        ensure  => $ensure_sudo_file,
        owner   => 'root',
        group   => 'root',
        mode    => '0440',
        content => epp('unix_accounts/sudofile.epp',
                       { 'user' => $login, }
                      ),
        require => [ Package['sudo'], User[$login] ],
      }

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

    file { "${home}/.bashrc.puppet":
      owner   => $login,
      group   => $login,
      mode    => '0644',
      require => User[$login],
      content => epp('unix_accounts/bashrc.puppet.epp',
                     { 'fqdn_in_prompt' => $fqdn_in_prompt, }
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
        @("END").regsubst('\n', ' ', 'G').fail
          ${title}: `$login` account should have the `$keyname` ssh key as
          authorized key but this key does not exist in the list of ssh
          public keys.
          |- END
      }

      ssh_authorized_key { "${login}~${keyname}":
        user => $login,
        type => $ssh_public_keys[$keyname]['type'],
        # Just to allow ssh_public_keys in hiera in multilines with ">".
        key  => $ssh_public_keys[$keyname]['keyvalue'].regsubst(' ', '', 'G').strip,
      }

    }

  }
  ########################################################
  ### End of the management of the ssh_authorized_keys ###
  ########################################################

}



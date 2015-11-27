class unix_accounts (
  Hash[String[1], Hash[String[1], Data, 1], 1]         $users,
  Hash[String[1], Hash[String[1], String[1], 2, 2], 1] $ssh_public_keys,
  Boolean                                              $fqdn_in_prompt,
  Array[String[1], 1]                                  $supported_distributions,
  String[1]                                            $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $packages = [ 'sudo' ]
  ensure_packages( $packages, { ensure => present } )

  $users.each |$user, $params| {

    # The "password" key is mandatory for each user.
    unless $params.has_key('password') and $params['password'] =~ String[1] {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: `$user` must have a password key which must be
        an non-empty string.
        |- END
    }

    # The "ensure" parameter is optional but must be 'present' or
    # 'absent'.
    if $params.has_key('ensure')
    and $params['ensure'] !~ Enum['present', 'absent'] {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: `$user` account has the `ensure` key but its value must
        be only 'present' or 'absent'.
        |- END
    }

    # The "is_sudo" parameter is optional but must be a boolean if it exists.
    if $params.has_key('is_sudo') and $params['is_sudo'] !~ Boolean {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: `$user` account has the `is_sudo` key but its value must
        be only a boolean.
        |- END
    }

    # The "ssh_authorized_keys" parameter is optional but must be a non-empty
    # array of non-empty strings if it exists.
    if $params.has_key('ssh_authorized_keys')
    and $params['ssh_authorized_keys'] !~ Array[String[1], 1] {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: `$user` account has the `ssh_authorized_keys` key but
        its value must be only a non-empty array of non-empty strings.
        |- END
    }

    $password = $params['password']

    if $params.has_key('ensure') {
      $ensure_account = $params['ensure']
    } else {
      $ensure_account = 'present' # the default value is 'present' of course.
    }

    if $params.has_key('is_sudo') and $params['is_sudo'] {
      $is_sudo              = true
      $supplementary_groups = [ 'sudo' ]
    } else {
      $is_sudo              = false
      $supplementary_groups = []
    }

    if $params.has_key('ssh_authorized_keys') {
      $ssh_authorized_keys = $params['ssh_authorized_keys']
    } else {
      $ssh_authorized_keys = []
    }

    # Management of the ssh_authorized_keys only if the user
    # has ensure == 'present'. If not, maybe the user exists
    # no longer and if he exists, he will be deleted.
    if $ensure_account == 'present' {

      $ssh_authorized_keys.each |$keyname| {

        unless $ssh_public_keys.has_key($keyname) {
          @("END").regsubst('\n', ' ', 'G').fail
            ${title}: `$user` account should have the `$keyname` ssh key as
            authorized key but this key does not exist in the list of ssh
            public keys.
            |- END
        }

        # We check that the keys 'type' and 'keyvalue' are present
        # in $ssh_public_keys[$keyname].
        [ 'type', 'keyvalue' ].each |$k| {
          unless $ssh_public_keys[$keyname].has_key($k) {
            @("END").regsubst('\n', ' ', 'G').fail
              ${title}: the ssh public key `$keyname` must be a hash
              with the key `$k` and this is not the case currently.
              |- END
          }
        }

        ssh_authorized_key { "${user}~${keyname}":
          user => $user,
          type => $ssh_public_keys[$keyname]['type'],
          # To allow ssh_public_keys in hiera in multilines with ">".
          key  => $ssh_public_keys[$keyname]['keyvalue'].regsubst(' ', '', 'G').strip,
        }

      }

    }

    if $user != 'root' {

      if $ensure_account == 'present' {
        $purge_ssh_keys = true
      } else {
        # If this parameter is set to true when the user has
        # "ensure => absent", it can trigger errors because
        # the home has been deleted and Puppet can no longer
        # manage the ssh authorized keys (even in order to
        # purge these keys).
        $purge_ssh_keys = false
      }

      user { $user:
        name           => $user,
        ensure         => $ensure_account,
        expiry         => absent,
        managehome     => true,
        home           => "/home/${user}",
        password       => $password,
        shell          => '/bin/bash',
        system         => false,
        groups         => $supplementary_groups,
        purge_ssh_keys => $purge_ssh_keys,
        require        => Package['sudo'],
      }

      # Just set to 0750 the Unix rights of the home directory
      # (instead of the default 0755).
      if $ensure_account == 'present' {
        file { "/home/${user}":
          ensure  => directory,
          owner   => $user,
          group   => $user,
          mode    => '0750',
          require => User[$user],
        }
      }

      # Management of the sudo file of $user.
      if $ensure_account == 'present' and $is_sudo {
        $ensure_sudo_file = 'present'
      } else {
        $ensure_sudo_file = 'absent'
      }

      file { "/etc/sudoers.d/${user}":
        ensure  => $ensure_sudo_file,
        owner   => 'root',
        group   => 'root',
        mode    => '0440',
        content => epp('unix_accounts/sudofile.epp',
                       { 'user' => $user, }
                      ),
        require => [
                     Package['sudo'],
                     User[$user],
                   ]
      }

      if $ensure_account == 'present' and !$is_sudo {
        # Unfortunately, with "groups => []", the account is
        # not automatically removed from the "sudo" group. So
        # we need to remove the account from this group manually.

        $members_of_sudo = @(END)
          getent group sudo | cut -d: -f4 | tr ',' '\n'
          |- END

        exec { "remove-${user}-from-the-sudo-group":
          command => "gpasswd --delete '${user}' sudo",
          onlyif  => "${members_of_sudo} | grep '^${user}$'",
          path    => '/usr/sbin:/usr/bin:/sbin:/bin',
          user    => 'root',
          group   => 'root',
          require => User[$user],
        }
      }

    } else {

      # $user == 'root' is a specific case.
      user { 'root':
        name           => 'root',
        ensure         => present,
        home           => '/root',
        password       => $password,
        purge_ssh_keys => true,
      }

    }

    # Management of .bashrc and .vimrc.
    if $ensure_account == 'present' or $user == 'root'  {

      if $user == 'root' {
        $homeuser = '/root'
      } else {
        $homeuser = "/home/${user}"
      }

      file_line { "edit-bashrc-of-${user}":
        path    => "${homeuser}/.bashrc",
        line    => ". ${homeuser}/.bashrc.puppet # Edited by Puppet.",
        require => User[$user],
      }

      file { "${homeuser}/.bashrc.puppet":
        owner   => $user,
        group   => $user,
        mode    => '0644',
        require => User[$user],
        content => epp('unix_accounts/bashrc.puppet.epp',
                       { 'fqdn_in_prompt' => $fqdn_in_prompt, }
                      ),
      }

      file { "${homeuser}/.vimrc":
        owner   => $user,
        group   => $user,
        mode    => '0644',
        require => User[$user],
        source  => 'puppet:///modules/unix_accounts/vimrc',
      }

    }

  } # End of the loop of users.

}



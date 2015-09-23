class unix_accounts (
  Hash[String[1], Hash[String[1], Data, 1], 1] $users,
  Array[String[1], 1]                          $supported_distributions,
  String[1]                                    $stage = 'main',
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
    if $params.has_key('ensure') and $params['ensure'] !~ Enum['present', 'absent'] {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: `$user` account has the `ensure` key but its value must
        be only 'present' or 'absent'.
        |- END
    }

    # The "sudo" parameter is optional but must be a boolean.
    if $params.has_key('sudo') and $params['sudo'] !~ Boolean {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: `$user` account has the `sudo` key but its value must
        be only a boolean.
        |- END
    }

    # The "sshkeys" parameter is optional but must be a non-empty
    # hash of non-empty strings.
    $type_sshkeys = Hash[String[1], String[1], 1]
    if $params.has_key('sshkeys') and $params['sshkeys'] !~ $type_sshkeys {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: `$user` account has the `sshkeys` key but its value must
        be only a non-empty hash of non-empty strings.
        |- END
    }

    $password = $params['password']

    if $params.has_key('ensure') {
      $ensure_account = $params['ensure']
    } else {
      $ensure_account = 'present' # the default value is 'present' of course.
    }

    if $params.has_key('sudo') and $params['sudo'] {
      $supplementary_groups = [ 'sudo' ]
    } else {
      $supplementary_groups = []
    }

    if $params.has_key('sshkeys') {
      $sshkeys = $params['sshkeys']
    } else {
      $sshkeys = []
    }

    # Management of the sshkeys only if the user has ensure == 'present'.
    # If not, maybe the user exists no longer and if he exists, he will
    # be deleted.
    if $ensure_account == 'present' {
      $sshkeys.each |$keyname, $value| {
        ssh_authorized_key { "${user}@${keyname}":
          user => $user,
          type => 'ssh-rsa',
          # To allow sshkeys in hiera in multilines with >.
          key  => $value.regsubst(' ', '', 'G').strip,
        }
      }
    }

    if $user != 'root' {

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
        purge_ssh_keys => true,
        before         => Package['sudo'],
      }

      if $ensure_account == 'present' and $supplementary_groups.empty {
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

  } # End of the loop of users.

}



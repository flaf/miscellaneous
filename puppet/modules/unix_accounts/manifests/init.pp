class unix_accounts (
  Array[String[1], 1] $supported_distributions,
  String[1]           $stage = 'main',
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $params_class    = '::unix_accounts::params'
  if !defined(Class[$params_class]) { include $params_class }
  $users           = $::unix_accounts::params::users
  $ssh_public_keys = $::unix_accounts::params::ssh_public_keys
  $fqdn_in_prompt  = $::unix_accounts::params::fqdn_in_prompt

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

    # The "home_unix_rights" parameter is optional but must be a non-empty
    # string if it exists and must match to Unix rights in octal format.
    if $params.has_key('home_unix_rights') {
      unless $params['home_unix_rights'] =~ String[1]
      and $params['home_unix_rights'] =~ /^[0-7]{3,4}$/ {
        @("END").regsubst('\n', ' ', 'G').fail
          ${title}: `$user` account has the `home_unix_rights` key but
          its value must be only a non-empty strings which matches with
          Unix rights in octal format.
          |- END
      }
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

    # The "supplementary_groups" parameter is optional but must be
    # array of non-empty strings if it exists.
    if $params.has_key('supplementary_groups')
    and $params['supplementary_groups'] !~ Array[String[1]] {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: `$user` account has the `supplementary_groups` key but
        its value must be only an array of non-empty strings.
        |- END
    }

    $password = $params['password']

    if $params.has_key('ensure') {
      $ensure_account = $params['ensure']
    } else {
      $ensure_account = 'present' # the default value is 'present' of course.
    }

    if $params.has_key('supplementary_groups') {
      $supp_grps_tmp = $params['supplementary_groups']
    } else {
      $supp_grps_tmp = []
    }

    if $params.has_key('home_unix_rights') {
      $home_unix_rights = $params['home_unix_rights']
    } else {
      $home_unix_rights = '0750'
    }

    if $params.has_key('is_sudo') and $params['is_sudo'] {
      $is_sudo              = true
      $supplementary_groups = unique( [ 'sudo' ] + $supp_grps_tmp )
    } else {
      $is_sudo              = false
      $supplementary_groups = unique( $supp_grps_tmp )
    }

    if $supplementary_groups.member($user) {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: `$user` account has the `supplementary_groups` which
        contains the group `$user`. It is forbidden because `$user` is
        automatically the primary group of the account. You must remove
        the group `$user` from the supplementary groups.
        |- END
    }

    if $supplementary_groups.member('sudo') and !$is_sudo {
      @("END").regsubst('\n', ' ', 'G').fail
        ${title}: `$user` account has the `supplementary_groups` which
        contains the group `sudo` but its parameter `is_sudo` set to false.
        It is inconsistent.
        |- END
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
          mode    => $home_unix_rights,
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

      # Remove the account from groups which are not in
      # the supplementary groups.
      # Exceptions: we don't handle the "sudo" group here
      # which is a specific case handled above (the primary
      # group $user is not seen as a supplementary group).
      if $ensure_account == 'present' {

        $suppl = sort($supplementary_groups - [ 'sudo' ]).join(':')

        # Command which returns 0 is there are too many groups
        # which contain the current user, else returns 1.
        #
        # (a) With the first grep, we remove the sudo group
        # and the primary group of the current user. With
        # the second grep, we take only the groups which
        # contain the current user.
        #
        # (b) If "$grps" is empty, there isn't too many
        # groups which contain the current user.
        #
        # (c) Now $grps is something like ":grp1:grp2:grp3:"
        # with all the groups which contain the current user
        # (except sudo and the primary group of the current
        # user) and the group names are sorted.
        #
        $cmd_too_many_grps = @(END).regsubst('__USER__', $user, 'G').regsubst('__SUPPL__', ":${suppl}:", 'G')
          grps=$(getent group | grep -Ev '^(__USER__|sudo):' \
                              | grep -E '(:|,)__USER__(,|$)' \
                              | cut -d':' -f1 | sort | tr '\n' ':') # (a)
          [ -z "$grps" ] && exit 1 # (b)
          grps=":$grps" # (c)
          if [ "$grps" = '__SUPPL__' ]; then exit 1; else exit 0; fi
          |- END

        $cmd_remove_user_from_groups = @(END).regsubst('__USER__', $user, 'G').regsubst('__SUPPL__', ":${suppl}:", 'G')
          grps=$(getent group | grep -Ev '^(__USER__|sudo):' \
                              | grep -E '(:|,)__USER__(,|$)' \
                              | cut -d':' -f1)
          for grp in $grps
          do
            printf '%s' '__SUPPL__'  | grep -q ":${grp}:" && continue
            gpasswd --delete '__USER__' "$grp"
          done
          |- END

        exec { "remove-${user}-from-groups-not-in-supplementary-groups":
          # Needed because the command is a shell script.
          provider => 'shell',
          command  => $cmd_remove_user_from_groups,
          onlyif   => $cmd_too_many_grps,
          path     => '/usr/sbin:/usr/bin:/sbin:/bin',
          user     => 'root',
          group    => 'root',
          require  => User[$user],
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



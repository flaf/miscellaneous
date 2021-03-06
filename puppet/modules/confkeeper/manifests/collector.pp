class confkeeper::collector {

  include '::confkeeper::collector::params'

  [
    $collection,
    $wrapper_cron,
    $hour_range_cron,
    $additional_exported_repos,
    $allinone_readers,
    $supported_distributions,
    #
    $non_bare_repos_path,
  ] = Class['::confkeeper::collector::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  with($hour_range_cron) |$range| {
    $min = $range[0]
    $max = $range[1]
    unless $min < $max {
      @("END"/L$).fail
        Class ${title}: the `hour_range_cron` parameter of the `params` class \
        is not correct because the first element must be strictly lower than \
        the second.
        |-END
    }
  }

  $fqdn = $::facts['networking']['fqdn']

  # Check $allinone_readers.
  $allinone_readers.each |$allinone_reader| {

    $username = $allinone_reader['username']

    if $username in ['admin', 'git'] {
      @("END"/L$).fail
        Class ${title}: username `git` and `admin` are forbidden \
        for the all-in-one readers in the parameter `allinone_readers`.
        |-END
    }

    if "\n" in $allinone_reader['ssh_pubkey'] {
      @("END"/L$).fail
        Class ${title}: username `${username}` in the `allinone_readers` \
        parameter has a `ssh_pubkey` value with a newline character which \
        is forbidden.
        |-END
    }

  }

  ensure_packages(['gitolite3', 'rsync'], { ensure => present })

  ###################################################
  ### Creation of git and gitolite-admin accounts ###
  ### and management of homes.                    ###
  ###################################################

  # A result of:
  #
  #     mkpasswd --method=sha-512 --salt="$(openssl rand -hex 8)" git
  #
  # So "git" is the password. But we don't care here because
  # the password will be locked below.
  $pwd = @(END/L)
    $6$8d7f75658c4bd0e3$pApb19j4GTGX1BfLJufjNS.znLLlwDbx3ztBMWb\
    RvBhgUu9tGwcnQNP911pEHGHIEeOU.8KGn9icD3Apoiq/2.
    |-END

  group {
    default:
      ensure          => present,
      auth_membership => true,
      system          => false,
      require         => Package['gitolite3']
    ;

    'git':
      members => ['git'],
    ;

    'gitolite-admin':
      members => ['gitolite-admin'],
    ;
  }

  user {
    default:
      ensure         => present,
      password       => "!${pwd}", # <= password locked via the "!" character.
      managehome     => false,
      shell          => '/bin/bash',
      membership     => 'inclusive',
      purge_ssh_keys => false,
      expiry         => absent,
      system         => false,
    ;

    'git':
      comment  => 'Git repository hosting',
      home     => '/home/git',
      groups   => ['git'],
      require  => Group['git'],
    ;

    'gitolite-admin':
      comment  => 'Gitolite administrator',
      home     => '/home/gitolite-admin',
      groups   => ['gitolite-admin'],
      require  => Group['gitolite-admin'],
    ;
  }

  file {
    default:
      ensure  => directory,
      mode    => '0700',
      purge   => false,
      recurse => false,
    ;

    '/home/git':
      owner   => 'git',
      group   => 'git',
      require => User['git'],
    ;

    '/home/gitolite-admin':
      owner   => 'gitolite-admin',
      group   => 'gitolite-admin',
      require => User['gitolite-admin'],
    ;

    '/home/gitolite-admin/.gitconfig':
      ensure  => file,
      mode    => '0644',
      owner   => 'gitolite-admin',
      group   => 'gitolite-admin',
      require => User['gitolite-admin'],
      content => epp('confkeeper/collector/dotgitconfig.epp',
                     {
                      'fqdn' => $fqdn,
                     }
                 ),
    ;
  }

  # Create a SSH keys for git and gitolite-admin.
  ['git', 'gitolite-admin'].each |$user| {
    exec { "create-ssh-keys-for-${user}":
      creates   => "/home/${user}/.ssh/id_rsa.pub",
      command   => @("END"/L$),
        ssh-keygen -b 4096 -t rsa -C "${user}@${fqdn}" -P "" \
        -f "/home/${user}/.ssh/id_rsa"
        |-END
      user      => $user,
      group     => $user,
      path      => '/usr/bin:/bin',
      cwd       => "/home/${user}",
      logoutput => 'on_failure',
      require   => File["/home/${user}"],
    }
  }

  file { '/home/git/admin.pub':
    ensure  => file,
    mode    => '0644',
    owner   => 'git',
    group   => 'git',
    source  => '/home/gitolite-admin/.ssh/id_rsa.pub',
    require => Exec['create-ssh-keys-for-gitolite-admin'],
  }

  exec { 'init-git-repository':
    environment => ['HOME=/home/git', 'USER=git'],
    creates     => '/home/git/repositories',
    command     => 'gitolite setup -pk /home/git/admin.pub',
    user        => 'git',
    group       => 'git',
    path        => '/usr/bin:/bin',
    cwd         => '/home/git',
    logoutput   => 'on_failure',
    require     => File['/home/git/admin.pub'],
  }

  ####################################################
  ### Management of the gitolite configuration via ###
  ### the "gitolite-admin" repository              ###
  ####################################################

  # To allow a local "git clone git@localhost:gitolite-admin.git"
  # without warning about fingerprint checking via the "git"
  # and "gitolite-admin" unix accounts.
  ['git', 'gitolite-admin'].each |$user| {
    sshkey {"localhost-for-${user}":
      ensure       => present,
      key          => $::facts['ssh']['rsa']['key'],
      type         => 'ssh-rsa',
      host_aliases => ['localhost', $::facts['networking']['fqdn']],
      target       => "/home/${user}/.ssh/known_hosts",
      require      => Exec['init-git-repository'],
    }
  }

  exec { 'clone-gitolite-admin.git':
    environment => ['HOME=/home/gitolite-admin', 'USER=gitolite-admin'],
    creates     => '/home/gitolite-admin/gitolite-admin',
    command     => "git clone git@localhost:gitolite-admin.git",
    user        => 'gitolite-admin',
    group       => 'gitolite-admin',
    path        => '/usr/bin:/bin',
    cwd         => '/home/gitolite-admin',
    logoutput   => 'on_failure',
    require     => [
                    Sshkey['localhost-for-git'],
                    Sshkey['localhost-for-gitolite-admin'],
                   ],
  }

  # The puppetdb query to retrieve all the "exported" repositories.
  $puppetdb_query = @("END")
    resources[parameters]{
      type = "Class" and title = "Confkeeper::Provider::Params"
        and parameters.collection = "${collection}"
        and nodes { deactivated is null and expired is null }
    }
    |-END

  $puppetdb_exported_repos = puppetdb_query($puppetdb_query)
  .map |$item| {
    $item['parameters']
  }
  .reduce({}) |$memo, $parameters| {

    $fqdn = $parameters['fqdn']

    if $fqdn in $memo {
      @("END"/L$).fail
        Class ${title}: multiple hosts have declared the class \
        Confkeeper::Provider::params with the same value `${fqdn}` \
        for the `fqdn` parameter. This is not allowed.
        |-END
    }

    # The etckeeper ssh public key is created during the
    # first puppet run of a provider but, during the
   # loading facts of this first puppet run, the key is
    # not yet defined and the value of the custom fact is
    # temporarily undef.
    if $parameters['etckeeper_ssh_pubkey'] =~ Undef {
      next($memo)
    }

    $memo + {
      $fqdn => {
      'ssh_pubkey'   => $parameters['etckeeper_ssh_pubkey'],
      'repositories' => $parameters['repositories'],
      }
    }

  } # End of $puppetdb_exported_repos.

  # We check that there is common fqdn between $puppetdb_exported_repos
  # and $additional_exported_repos.
  $additional_exported_repos.each |$fqdn, $repos| {
    if $fqdn in $puppetdb_exported_repos {
      @("END"/L$).fail
        Class ${title}: the fqdn `${fqdn}` is present simultaneously in \
        the parameter `\$additional_exported_repos` and in the exported \
        repositories from the Puppetdb, this is not allowed.
        |-END
    }
  }

  # All the exported repositories.
  $exported_repos = ($additional_exported_repos + $puppetdb_exported_repos)
  .reduce({}) |$memo, $item| {

    [$fqdn, $params] = $item

    $account = $params.dig('account').lest || {'root'}

    $repositories_completed = ::confkeeper::complete_repos_settings(
      $params['repositories'],
      $account,
      $fqdn,
    )

    $new_params = $params + {
      'account'      => $account,
      'repositories' => $repositories_completed
    }

    $memo + {$fqdn => $new_params}

  } # End of $exported_repos

  file { '/home/gitolite-admin/gitolite-admin/conf/gitolite.conf':
    ensure  => file,
    mode    => '0644',
    owner   => 'gitolite-admin',
    group   => 'gitolite-admin',
    require => Exec['clone-gitolite-admin.git'],
    notify  => [Exec['commit-push-gitolite-admin.git'], Exec['mv-old-repos']],
    content => epp('confkeeper/collector/gitolite.conf.epp',
                   {
                     'exported_repos'   => $exported_repos,
                     'allinone_readers' => $allinone_readers,
                   }
                  ),
  }

  file { '/home/gitolite-admin/gitolite-admin/keydir':
    ensure  => directory,
    mode    => '0755',
    purge   => true,
    recurse => true,
    require => Exec['clone-gitolite-admin.git'],
    notify  => Exec['commit-push-gitolite-admin.git'],
  }

  $h = {'git' => 'git', 'gitolite-admin' => 'admin'}
  $h.each |$user, $keyname| {
    file { "/home/gitolite-admin/gitolite-admin/keydir/${keyname}.pub":
      ensure  => file,
      mode    => '0644',
      owner   => 'gitolite-admin',
      group   => 'gitolite-admin',
      source  => "/home/${user}/.ssh/id_rsa.pub",
      require => Exec['clone-gitolite-admin.git'],
      notify  => Exec['commit-push-gitolite-admin.git'],
    }
  }

  $exported_repos.each |$fqdn, $settings| {

    $ssh_pubkey = $settings['ssh_pubkey']
    $account    = $settings['account']

    file { "/home/gitolite-admin/gitolite-admin/keydir/${account}@${fqdn}.pub":
      ensure  => file,
      mode    => '0644',
      owner   => 'gitolite-admin',
      group   => 'gitolite-admin',
      content => "${ssh_pubkey}\n",
      require => Exec['clone-gitolite-admin.git'],
      notify  => Exec['commit-push-gitolite-admin.git'],
    }

  }

  $allinone_readers.each |$allinone_reader| {

    $ssh_pubkey = $allinone_reader['ssh_pubkey']
    $username   = $allinone_reader['username']

    file { "/home/gitolite-admin/gitolite-admin/keydir/${username}.pub":
      ensure  => file,
      mode    => '0644',
      owner   => 'gitolite-admin',
      group   => 'gitolite-admin',
      content => "${ssh_pubkey}\n",
      require => Exec['clone-gitolite-admin.git'],
      notify  => Exec['commit-push-gitolite-admin.git'],
    }

  }

  exec { 'commit-push-gitolite-admin.git':
    environment => ['HOME=/home/gitolite-admin', 'USER=gitolite-admin'],
    command     => @(END/L),
      sh -c 'git add . && git commit -m "Automatic Puppet commit" && git push'
      |-END
    user        => 'gitolite-admin',
    group       => 'gitolite-admin',
    path        => '/usr/bin:/bin',
    cwd         => '/home/gitolite-admin/gitolite-admin',
    logoutput   => 'on_failure',
    refreshonly => true,
  }

  file { '/usr/local/bin/mv-old-repos':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    require => Exec['commit-push-gitolite-admin.git'],
    content => epp('confkeeper/collector/mv-old-repos.epp',
                   {
                    'non_bare_repos_path' => $non_bare_repos_path,
                   }
               ),
  }

  exec { 'mv-old-repos':
    environment => ['HOME=/home/git'],
    command     => 'mv-old-repos',
    user        => 'git',
    group       => 'git',
    path        => '/usr/local/bin:/usr/bin:/bin',
    cwd         => '/home/git',
    logoutput   => 'on_failure',
    refreshonly => true,
    require     => File['/usr/local/bin/mv-old-repos'],
  }

  file { '/usr/local/bin/collect-all-git-repos':
    ensure  => file,
    mode    => '0755',
    owner   => 'root',
    group   => 'root',
    content => epp('confkeeper/collector/collect-all-git-repos.epp',
                   {
                    'non_bare_repos_path' => $non_bare_repos_path,
                   }
               ),
  }

  $seed = 'etckeeper-push-all'

  $cron_hour = with($hour_range_cron) |$range| {
    $min = $range[0]
    $max = $range[1]
    $min + fqdn_rand($max-$min, $seed)
  }

  $cron_cmd = case $wrapper_cron {
    Undef:   { '/usr/local/bin/collect-all-git-repos'                 }
    default: { "${wrapper_cron} /usr/local/bin/collect-all-git-repos" }
  }

  cron { 'collect-all-git-repos':
    ensure   => present,
    user     => 'git',
    command  => $cron_cmd,
    hour     => $cron_hour,
    minute   => fqdn_rand(60, $seed),    # from 0 to 59
    monthday => absent,                  # ie *
    month    => absent,                  # ie *
    weekday  => absent,                  # ie *
    require  => File['/usr/local/bin/collect-all-git-repos'],
  }

}



class confkeeper::collector {

  include '::confkeeper::collector::params'

  [
    $collection,
    $supported_distributions,
  ] = Class['::confkeeper::collector::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  include '::confkeeper::provider::params'

  [
    $etckeeper_known_hosts,
  ] = Class['::confkeeper::provider::params']

  ensure_packages(['gitolite3'], { ensure => present })


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
  $pwd = '$6$8d7f75658c4bd0e3$pApb19j4GTGX1BfLJufjNS.znLLlwDbx3ztBMWbRvBhgUu9tGwcnQNP911pEHGHIEeOU.8KGn9icD3Apoiq/2.'

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
      password       => "!${pwd}", # <= password locked with "!".
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
      content => epp('confkeeper/collector/dotgitconfig.epp', {}),
    ;
  }

  $fqdn = $::facts['networking']['fqdn']

  exec { 'create-ssh-keys-for-gitolite-admin':
    creates   => '/home/gitolite-admin/.ssh/id_rsa.pub',
    command   => "ssh-keygen -b 4096 -t rsa -C 'gitolite-admin@${fqdn}' -P '' -f /home/gitolite-admin/.ssh/id_rsa",
    user      => 'gitolite-admin',
    group     => 'gitolite-admin',
    path      => '/usr/bin:/bin',
    cwd       => '/home/gitolite-admin',
    logoutput => 'on_failure',
    require   => File['/home/gitolite-admin'],
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
    command     => "gitolite setup -pk /home/git/admin.pub",
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
  # without warning about fingerprint checking.
  sshkey {'localhost':
    ensure       => present,
    key          => $::facts['ssh']['rsa']['key'],
    type         => 'ssh-rsa',
    target       => '/home/gitolite-admin/.ssh/known_hosts',
    require      => Exec['init-git-repository'],
  }

  # ssh host key of the confkeeper server is exported.
  @@sshkey {$::facts['networking']['fqdn']:
    ensure       => present,
    key          => $::facts['ssh']['rsa']['key'],
    type         => 'ssh-rsa',
    target       => $etckeeper_known_hosts,
    tag          => $collection,
  }

  exec { 'clone-gitolite-admin.git':
    creates   => '/home/gitolite-admin/gitolite-admin',
    command   => "git clone git@localhost:gitolite-admin.git",
    user      => 'gitolite-admin',
    group     => 'gitolite-admin',
    path      => '/usr/bin:/bin',
    cwd       => '/home/gitolite-admin',
    logoutput => 'on_failure',
    require   => Sshkey['localhost'],
  }

  $puppetdb_query = "resources[parameters, certname]{ tag = '${collection}' and type = 'Confkeeper::Provider::Repos' and exported = true }"
  $exported_repos = puppetdb_query($puppetdb_query)

  $repos_by_host = $exported_repos.reduce({}) |$memo, $exported_repo| {

    $certname         = $exported_repo['certname']
    $ssh_pubkey       = $exported_repo['parameters']['etckeeper_ssh_pubkey']
    $certname_in_memo = ($certname in $memo)

    if $certname_in_memo and $memo[$certname]['ssh_pubkey'] != $ssh_pubkey {
      @("END"/L$).fail
        Class ${title}: the host ${certname} seems to have \
        multiple Confkeeper::Provider::Repos exported resources \
        but not with the same `etckeeper_ssh_pubkey` at each time. \
        This is not allowed.
        |-END
    }

    # The etckeeper ssh public key has probably been created
    # but during the loading facts of the first puppet run,
    # this is not the case and the custom fact gives an empty
    # string.
    if $ssh_pubkey == '' { next($memo) }

    $directories = case $certname_in_memo {
      true: {
        ($memo[$certname]['directories'] + $exported_repo['parameters']['directories']).unique
      }
      default: {
        $exported_repo['parameters']['directories']
      }
    }

    $memo + {$certname => {'ssh_pubkey' => $ssh_pubkey, 'directories' => $directories}}

  }

  $repositories = $repos_by_host.reduce([]) |$memo, $repos_host| {

    $certname = $repos_host[0]
    $repos    = $repos_host[1]['directories'].map |$dir| { "${certname}${dir}.git"}

    $memo + { 'relapath' => ${certname}/}

  }

  [
    {
      'relapath'    => 'toto/titi.git',
      'permissions' => [{'rights' => 'RW+', 'target' => 'admin'}],
    },
    {
      'relapath'    => 'tutu/titi.git',
      'permissions' => [{'rights' => 'RW+', 'target' => 'admin'}],
    },
  ]

  file { '/home/gitolite-admin/gitolite-admin/conf/gitolite.conf':
    ensure  => file,
    mode    => '0644',
    owner   => 'gitolite-admin',
    group   => 'gitolite-admin',
    require => Exec['clone-gitolite-admin.git'],
    notify  => [Exec['commit-push-gitolite-admin.git'], Exec['mv-old-repos']],
    content => epp('confkeeper/collector/gitolite.conf.epp',
                   {
                     'repositories' => $repositories,
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

  file { '/home/gitolite-admin/gitolite-admin/keydir/admin.pub':
    ensure  => file,
    mode    => '0644',
    owner   => 'gitolite-admin',
    group   => 'gitolite-admin',
    source  => '/home/git/admin.pub',
    require => Exec['clone-gitolite-admin.git'],
    notify  => Exec['commit-push-gitolite-admin.git'],
  }

  #$sshpubkeys = [
  #  {
  #    'name'    => 'bob',
  #    'type'    => 'ssh-rsa',
  #    'value'   => 'AAAB3NzaC1yc2EAAAADAQABAAAAgQC/R1WcUYqwY0x2L/EGRPwUF4KJ6UWo6ml4hGxMy+uNoqW59zlCJAguZDKyS8AHN7WoLIoRzcwxAru5iu9YjadgmdpOTfAXUCBEfKGWCVu0LxYuEcQYlBB1cayGZvKdG0uX0v1ibVPeDpfeXxe+ASKJ+fxqBuRyUcauCeBop+RUFQ==',
  #    'comment' => 'bob@srv1',
  #  },
  #]

  $repos_by_host.each |$certname, $settings| {

    $ssh_pubkey = $settings['ssh_pubkey']

    file { "/home/gitolite-admin/gitolite-admin/keydir/root@${certname}.pub":
      ensure  => file,
      mode    => '0644',
      owner   => 'gitolite-admin',
      group   => 'gitolite-admin',
      content => "${ssh_pubkey}\n",
      require => Exec['clone-gitolite-admin.git'],
      notify  => Exec['commit-push-gitolite-admin.git'],
    }

  }

  #$exported_repos.each |$exported_repo| {

  #  $ssh_pubkey = $exported_repo['parameters']['etckeeper_ssh_pubkey']
  #  $name       = $exported_repo['certname']

  #  file { "/home/gitolite-admin/gitolite-admin/keydir/${name}.pub":
  #    ensure  => file,
  #    mode    => '0644',
  #    owner   => 'gitolite-admin',
  #    group   => 'gitolite-admin',
  #    content => "${ssh_pubkey}\n",
  #    require => Exec['clone-gitolite-admin.git'],
  #    notify  => Exec['commit-push-gitolite-admin.git'],
  #  }

  #}

#  $sshpubkeys.each |Confkeeper::SshPubKey $sshpubkey| {
#    $name    = $sshpubkey['name']
#    $type    = $sshpubkey['type']
#    $value   = $sshpubkey['value']
#    $comment = $sshpubkey['comment']
#
#    file { "/home/gitolite-admin/gitolite-admin/keydir/${name}.pub":
#      ensure  => file,
#      mode    => '0644',
#      owner   => 'gitolite-admin',
#      group   => 'gitolite-admin',
#      content => "${type} ${value} ${comment}\n",
#      require => Exec['clone-gitolite-admin.git'],
#      notify  => Exec['commit-push-gitolite-admin.git'],
#    }
#  }

  exec { 'commit-push-gitolite-admin.git':
    command     => "sh -c 'git add . && git commit -m \"Automatic Puppet commit\" && git push'",
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
    content => epp('confkeeper/collector/mv-old-repos.epp', {}),
  }

  exec { 'mv-old-repos':
    environment => ['HOME=/home/git'],
    command     => 'mv-old-repos',
    user        => 'git',
    group       => 'git',
    path        => '/usr/local/bin:/usr/bin:/bin',
    logoutput   => 'on_failure',
    refreshonly => true,
    require     => File['/usr/local/bin/mv-old-repos'],
  }

}



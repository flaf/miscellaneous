class confkeeper::collector {

  include '::confkeeper::collector::params'

  [
    $supported_distributions,
  ] = Class['::confkeeper::collector::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ensure_packages(['gitolite3'], { ensure => present })

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
    environment => ['HOME=/home/git'],
    creates     => '/home/git/repositories',
    command     => "gitolite setup -pk /home/git/admin.pub",
    user        => 'git',
    group       => 'git',
    path        => '/usr/bin:/bin',
    cwd         => '/home/git',
    logoutput   => 'on_failure',
    require     => File['/home/git/admin.pub'],
  }

  # To allow a local "git clone git@localhost:gitolite-admin.git"
  # without warning about fingerprint checking.
  sshkey {$::facts['networking']['fqdn']:
    ensure       => present,
    host_aliases => ['localhost'],
    key          => $::facts['ssh']['rsa']['key'],
    type         => 'ssh-rsa',
    require      => Exec['init-git-repository'],
  }

  exec { 'clone-gitolite-admin.git':
    creates   => '/home/gitolite-admin/gitolite-admin',
    command   => "git clone git@localhost:gitolite-admin.git",
    user      => 'gitolite-admin',
    group     => 'gitolite-admin',
    path      => '/usr/bin:/bin',
    cwd       => '/home/gitolite-admin',
    logoutput => 'on_failure',
    require   => Sshkey[$::facts['networking']['fqdn']],
  }

  file { '/home/gitolite-admin/gitolite-admin/keydir':
    ensure  => directory,
    mode    => '0755',
    purge   => true,
    recurse => true,
    require => Exec['clone-gitolite-admin.git'],
  }

  file { '/home/gitolite-admin/gitolite-admin/keydir/admin.pub':
    ensure  => file,
    mode    => '0644',
    owner   => 'gitolite-admin',
    group   => 'gitolite-admin',
    source  => '/home/git/admin.pub',
    require => Exec['clone-gitolite-admin.git'],
  }

  file { '/home/gitolite-admin/gitolite-admin/conf/gitolite.conf':
    ensure  => file,
    mode    => '0644',
    owner   => 'gitolite-admin',
    group   => 'gitolite-admin',
    require => Exec['clone-gitolite-admin.git'],
    content => epp('confkeeper/collector/gitolite.conf.epp',
                   {
                     'repositories' => $repositories,
                   }
                  ),
  }
}



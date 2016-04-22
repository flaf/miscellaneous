class puppetforge {

  include '::puppetforge::params'
  $puppetforge_git_url = $::puppetforge::params::puppetforge_git_url
  $commit_id           = $::puppetforge::params::commit_id
  $remote_forge        = $::puppetforge::params::remote_forge
  $address             = $::puppetforge::params::address
  $port                = $::puppetforge::params::port
  $pause               = $::puppetforge::params::pause
  $modules_git_urls    = $::puppetforge::params::modules_git_urls
  $release_retention   = $::puppetforge::params::release_retention
  $sshkeypair          = $::puppetforge::params::sshkeypair # undef is allowed
  # undef not allowed here.
  $puppet_bin_dir      = ::homemade::getvar('::puppetforge::params::puppet_bin_dir', $title)

  # Some specific directories or files.
  $homedir               = '/var/lib/puppetforge'
  $modulesdir            = "${homedir}/modules"
  $cachedir              = "${homedir}/cache"
  $gitdir                = "${homedir}/git"
  $giturlsfile           = "${homedir}/giturls.conf"
  $sshdir                = "${homedir}/.ssh"
  $logdir                = '/var/log/puppetforge'
  $workdir               = '/opt/puppetforge-server'
  $puppetforge_pid       = "${homedir}/puppetforge.pid"
  $update_pp_modules_pid = "${homedir}/update-pp-modules.pidpuppet_bin_dirbin       = '/usr/local/bin/puppetforge'

  # 'jq' is a cli to read json in command line.
  $packages = [ 'bundler', 'ruby-dev', 'build-essential', 'git', 'jq', 'sudo' ]
  ensure_packages( $packages,
                   { ensure => present,
                     before => Exec['install-puppetforge-server'],
                   }
                 )

  # Script to make a quick install of the puppet forge server
  # via the git repository.
  $script_install = @("END")
    [ ! -d '/opt' ] && mkdir '/opt'
    cd '/opt'
    { git clone '$puppetforge_git_url' puppetforge-server && cd '${workdir}'; } || exit 1
    git reset --hard '${commit_id}'
    bundle install || exit 1
    # We must use the gem command from the distribution environment.
    /usr/bin/gem install redcarpet
    echo "Puppet forge server installed."
    | END

  exec { 'install-puppetforge-server':
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    command => $script_install,
    unless  => "test -d '${workdir}'",
    before  => User['puppetforge'],
    notify  => Service['puppetforge'],
  }

  # We absolutely don't care about the password of this account
  # which will be disabled, because of the "!" character at the
  # begin of the hash password.
  $pwd = @(END/L)
    !$6$8532054bba$XMdu1vK/k48rWNrpDoca3e7tpdS8Dcv1HrXEbxRcn8H2\
    GkaUhLDJZXlzXKtDkn74rQwlQmsGT8pVEL9G2bkXB.
    |- END

  # The Unix account used to run the puppet forge server.
  user { 'puppetforge':
    name       => 'puppetforge',
    ensure     => present,
    comment    => 'Puppet Forge,,,',
    expiry     => absent,
    managehome => true,
    home       => $homedir,
    password   => $pwd,
    shell      => '/bin/bash',
    system     => false,
    notify     => Service['puppetforge'],
  }

  file { [ $homedir, $modulesdir, $cachedir, $logdir, $gitdir ]:
    ensure  => directory,
    owner   => 'puppetforge',
    group   => 'puppetforge',
    mode    => '0750',
    require => User['puppetforge'],
    before  => File[$puppetforge_bin],
    notify  => Service['puppetforge'],
  }

  file { $sshdir:
    ensure  => directory,
    owner   => 'puppetforge',
    group   => 'puppetforge',
    mode    => '0700',
    require => User['puppetforge'],
    before  => File[$puppetforge_bin],
    notify  => Service['puppetforge'],
  }

  if $sshkeypair =~ NotUndef {

    $privkey = $sshkeypair['privkey'].strip
    $pubkey  = $sshkeypair['pubkey'].regsubst(' ', '', 'G').strip

    file { "${sshdir}/id_rsa":
      ensure  => present,
      owner   => 'puppetforge',
      group   => 'puppetforge',
      mode    => '0600',
      require => File[$sshdir],
      notify  => Service['update-pp-modules'],
      content => "${privkey}\n",
    }

    file { "${sshdir}/id_rsa.pub":
      ensure  => present,
      owner   => 'puppetforge',
      group   => 'puppetforge',
      mode    => '0644',
      require => File[$sshdir],
      notify  => Service['update-pp-modules'],
      content => "ssh-rsa ${pubkey} Puppetforge\n",
    }

  }

  file { $puppetforge_bin:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => User['puppetforge'],
    notify  => Service['puppetforge'],
    content => epp( 'puppetforge/puppetforge.epp',
                    {
                      'workdir'         => $workdir,
                      'homedir'         => $homedir,
                      'address'         => $address,
                      'port'            => $port,
                      'modulesdir'      => $modulesdir,
                      'remote_forge'    => $remote_forge,
                      'cachedir'        => $cachedir,
                      'logdir'          => $logdir,
                      'puppetforge_pid' => $puppetforge_pid,
                    }
                  ),
  }

  file { '/etc/systemd/system/puppetforge.service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Service['puppetforge'],
    notify  => Service['puppetforge'],
    require => File[$puppetforge_bin],
    content => epp('puppetforge/puppetforge-unit.epp',
                   {
                    'puppetforge_pid' => $puppetforge_pid,
                    'puppetforge_bin' => $puppetforge_bin,
                   }
                  ),
  }

  $sudo_content = @(END)
    ### This file is managed by Puppet, don't edit it. ###
    puppetforge ALL = NOPASSWD: /usr/sbin/service puppetforge *
    | END

  file { '/etc/sudoers.d/puppetforge':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0440',
    before  => Service['puppetforge'],
    require => Package['sudo'],
    content => $sudo_content,
  }

  service { 'puppetforge':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }

  file { $giturlsfile:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '644',
    before  => Service['update-pp-modules'],
    notify  => Service['update-pp-modules'],
    content => epp('puppetforge/giturls.conf.epp',
                   { 'modules_git_urls' => $modules_git_urls, }
                  ),
    }

  file { '/usr/local/bin/update-pp-modules':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '755',
    before  => Service['update-pp-modules'],
    notify  => Service['update-pp-modules'],
    content => epp('puppetforge/update-pp-modules.epp',
                   {
                     'gitdir'                => $gitdir,
                     'modulesdir'            => $modulesdir,
                     'giturlsfile'           => $giturlsfile,
                     'pause'                 => $pause,
                     'release_retention'     => $release_retention,
                     'puppet_bin_dir'        => $puppet_bin_dir,
                     'update_pp_modules_pid' => $update_pp_modules_pid,
                   }
                  ),
    }

  file { '/etc/systemd/system/update-pp-modules.service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Service['update-pp-modules'],
    notify  => Service['update-pp-modules'],
    require => File['/usr/local/bin/update-pp-modules'],
    content => epp('puppetforge/update-pp-modules-unit.epp',
                   { 'update_pp_modules_pid' => $update_pp_modules_pid, }
                  ),
  }

  service { 'update-pp-modules':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }

}



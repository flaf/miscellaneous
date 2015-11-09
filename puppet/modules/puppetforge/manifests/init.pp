# TODO: implement the service "update-pp-module" via a push
#       system (ie the host receives a message from the
#       git server and so trigger an update locally.
#
class puppetforge (
  String[1]           $puppetforge_git_url,
  String[1]           $commit_id,
  String[1]           $remote_forge,
  String[1]           $address,
  Integer[1]          $port,
  Integer[1]          $pause,
  Array[String[1]]    $modules_git_urls,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # Some specific directories or files.
  $homedir               = '/var/lib/puppetforge'
  $modulesdir            = "${homedir}/modules"
  $cachedir              = "${homedir}/cache"
  $gitdir                = "${homedir}/git"
  $giturlsfile           = "${homedir}/giturls.conf"
  $logdir                = '/var/log/puppetforge'
  $workdir               = '/opt/puppetforge-server'
  $puppetforge_pid       = "${homedir}/puppetforge.pid"
  $update_pp_modules_pid = "${homedir}/update-pp-modules.pid"
  $puppetforge_bin       = '/usr/local/bin/puppetforge'

  # 'jq' is a cli to read json in command line.
  $packages = [ 'bundler', 'ruby-dev', 'build-essential', 'git', 'jq' ]
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
    echo "Puppet forge server installed."
    | END

  exec { 'install-puppetforge-server':
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    command => $script_install,
    unless  => "test -d '${workdir}'",
    before  => User['puppetforge'],
  }

  # We absolutely don't care about the password of this account
  # which will be disabled, because of the "!" character at the
  # begin of the hash password.
  $pwd = '!$6$8532054bba$XMdu1vK/k48rWNrpDoca3e7tpdS8Dcv1HrXEbxRcn8H2GkaUhLDJZXlzXKtDkn74rQwlQmsGT8pVEL9G2bkXB.'

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
  }

  file { [ $homedir, $modulesdir, $cachedir, $logdir, $gitdir ]:
    ensure  => directory,
    owner   => 'puppetforge',
    group   => 'puppetforge',
    mode    => '0750',
    require => User['puppetforge'],
    before  => File[$puppetforge_bin],
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



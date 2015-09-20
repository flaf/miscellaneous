# TODO: implement the service "update-pp-module" via a push
#       system (ie the host receives a message from the
#       git server and so trigger an update locally.
#
class puppet_forge (
  String[1]           $git_url,
  String[1]           $commit_id,
  String[1]           $remote_forge,
  String[1]           $address,
  Integer[1]          $port,
  Integer[1]          $pause,
  Array[String[1]]    $giturls,
  Array[String[1], 1] $supported_distributions,
) {

  ::homemade::is_supported_distrib($supported_distributions, $title)

  # Some specific directories or files.
  $homedir     = '/var/lib/puppetforge'
  $modulesdir  = "${homedir}/modules"
  $cachedir    = "${homedir}/cache"
  $gitdir      = "${homedir}/git"
  $giturlsfile = "${homedir}/giturls.conf"
  $logdir      = '/var/log/puppetforge'
  $workdir     = '/opt/puppet-forge-server'

  # 'jq' is a cli to read json in command line.
  $packages = [ 'bundler', 'ruby-dev', 'build-essential', 'git', 'jq' ]
  ensure_packages( $packages,
                   { ensure => present,
                     before => Exec['install-puppet-forge-server'],
                   }
                 )

  # Script to make a quick install of the puppet forge server
  # via the git repository.
  $script_install = @("END")
    [ ! -d '/opt' ] && mkdir '/opt'
    cd '/opt'
    { git clone '$git_url' && cd 'puppet-forge-server/'; } || exit 1
    git reset --hard '$commit_id'
    bundle install || exit 1
    echo "Puppet forge server installed."
    | END

  exec { 'install-puppet-forge-server':
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
    shell      => '/bin/false',
    system     => false,
  }

  file { [ $homedir, $modulesdir, $cachedir, $logdir, $gitdir ]:
    ensure  => directory,
    owner   => 'puppetforge',
    group   => 'puppetforge',
    mode    => '0750',
    require => User['puppetforge'],
    before  => File['/usr/local/bin/puppet-forge'],
  }

  file { '/usr/local/bin/puppet-forge':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    require => User['puppetforge'],
    notify  => Service['puppet-forge'],
    content => epp( 'puppet_forge/puppet-forge.epp',
                    { 'workdir'      => $workdir,
                      'homedir'      => $homedir,
                      'address'      => $address,
                      'port'         => $port,
                      'modulesdir'   => $modulesdir,
                      'remote_forge' => $remote_forge,
                      'cachedir'     => $cachedir,
                      'logdir'       => $logdir,
                    }
                  ),
  }

  file { '/lib/systemd/system/puppet-forge.service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Service['puppet-forge'],
    notify  => Service['puppet-forge'],
    require => File['/usr/local/bin/puppet-forge'],
    content => epp('puppet_forge/puppet-forge-unit.epp',
                   { 'homedir' => $homedir }),
  }

  service { 'puppet-forge':
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
    content => epp('puppet_forge/giturls.epp',
                   { 'giturls' => $giturls, }
                  ),
    }

  file { '/usr/local/bin/update-pp-modules':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '755',
    content => epp('puppet_forge/update-pp-modules.epp',
                   { 'gitdir'      => $gitdir,
                     'modulesdir'  => $modulesdir,
                     'giturlsfile' => $giturlsfile,
                     'pause'       => $pause,
                   }
                  ),
    }

  file { '/lib/systemd/system/update-pp-modules.service':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Service['update-pp-modules'],
    notify  => Service['update-pp-modules'],
    require => File['/usr/local/bin/update-pp-modules'],
    content => epp('puppet_forge/update-pp-modules-unit.epp',
                   { 'homedir' => $homedir }),
  }

  service { 'update-pp-modules':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }

}



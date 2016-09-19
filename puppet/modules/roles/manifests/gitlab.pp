class roles::gitlab {

  include '::roles::generic_nullclient'
  include '::repository::gitlab'

  class { '::gitlab::params':
    backup_cron_wrapper => ::roles::wrap_cron_mon(undef, 'backup-gitlab'),
  }

  class { '::rsyncd::params':
    # The rsync user "gitlab" and its password must be defined
    # in the hiera configuration.
    #users  => { 'gitlab' => 'xxx...xxx' },
    modules => {
      'backup' => {
        'path'       => $::gitlab::params::local_backup_dir,
        'read_only'  => true,
        'uid'        => 'root',
        'gid'        => 'root',
        'auth_users' => ['gitlab'],
      }
    }
  }

  include '::rsyncd'

  class { '::gitlab':
    require => Class['::repository::gitlab']
  }

}



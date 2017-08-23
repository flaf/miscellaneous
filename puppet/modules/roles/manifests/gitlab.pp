class roles::gitlab {

  include '::roles::generic_nullclient'
  include '::repository::gitlab'

  $cron_backup_name = 'backup-gitlab'

  class { '::gitlab::params':
    backup_cron_wrapper => ::roles::wrap_cron_mon($cron_backup_name),
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

  # Add a checpoint to check the backup.

  $gitlab_checkpoint_title = $::facts['networking']['fqdn'].with |$fqdn| {
    "${fqdn} from ${title}"
  }

  monitoring::host::checkpoint {$gitlab_checkpoint_title:
    templates        => ['linux_tpl', 'https_tpl'],
    custom_variables => [
      {
        'varname' => '_crons',
        'value'   => {"cron-${cron_backup_name}" => [$cron_backup_name, '1d']},
        'comment' => ["There is a daily Gitlab backup (${cron_backup_name})."],
      }
    ],
  }

}



class roles::gitlab {

  # With gitlab, we have to add "/gitlab/" in the gitignore
  # of the /opt local repository.
  $default_repos = lookup('confkeeper::provider::params::repositories')
  $opt_gitignore = $default_repos['/opt']['gitignore'] + ['/gitlab/']
  $final_repo    = $default_repos + {'/opt' => {'gitignore' => $opt_gitignore}}

  class {'::roles::generic':
    nullclient     => true,
    classes_params => {
      'confkeeper::provider::params::repositories' => $final_repo,
    },
  }

  include '::repository::gitlab'

  $cron_backup_name = 'backup-gitlab'

  class { '::gitlab::params':
    backup_cron_wrapper => ::roles::wrap_cron_mon($cron_backup_name),
  }

  # For monitoring.
  $external_url      = $::gitlab::params::external_url
  $external_fqdn     = $external_url.regsubst(Regexp.new('^https?://'), '')
  $sign_in_regex     = $::gitlab::params::sign_in_regex
  $health_page_token = $::gitlab::params::health_page_token

  if $sign_in_regex =~ Undef {
    @("END"/L$).fail
      ${title}: sorry you must define the parameter \
      `gitlab::params::sign_in_regex` for this role.
      |- END
  }

  if $health_page_token =~ Undef {
    @("END"/L$).fail
      ${title}: sorry you must define the parameter \
      `gitlab::params::health_page_token` for this role.
      |- END
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

  # Add a checkpoint to check the backup.

  $gitlab_checkpoint_title = $::facts['networking']['fqdn'].with |$fqdn| {
    "${fqdn} from ${title}"
  }

  $custom_variables = [
    {
      'varname' => '_crons',
      'value'   => {"cron-${cron_backup_name}" => [$cron_backup_name, '1d']},
      'comment' => ["There is a daily Gitlab backup (${cron_backup_name})."],
    },
    {
      'varname' => '_https_pages',
      'value'   => {
        'https-sign-page' => ["${external_fqdn}/users/sign_in", $sign_in_regex],
        'health-page'     => ["${external_fqdn}/health_check?token=${health_page_token}", '^success$$'],
      },
    },
  ]

  $extra_info = case $::facts['networking']['fqdn'] == $external_fqdn {
    false: {
      {
        'check_dns' => {
          "DNS-${external_fqdn}" => {
            'fqdn'             => $external_fqdn,
            'expected-address' => '$HOSTADDRESS$'
          },
        }
      }
    }
    default: {
      undef
    }
  }

  monitoring::host::checkpoint {$gitlab_checkpoint_title:
    templates        => ['linux_tpl', 'https_tpl'],
    custom_variables => $custom_variables,
    extra_info       => $extra_info,
  }

}



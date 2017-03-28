class gitlab::params (
  Pattern[/^https?:\/\//] $external_url,
  Gitlab::LdapConf    $ldap_conf,
  Array[String[1]]    $custom_nginx_config,
  Integer[1]          $backup_retention,
  String              $backup_cron_wrapper,
  Integer             $backup_cron_hour,
  Integer             $backup_cron_minute,
  String              $ssl_cert,
  String              $ssl_key,
  Array[String[1], 1] $supported_distributions,
) {

  $gitlab_backup_dir  = '/var/opt/gitlab/backups'
  $local_backup_dir   = '/localbackup'
  $backup_cmd         = '/usr/local/sbin/gitlab-backup.puppet'
  $etcgitlab_targz    = 'etcgitlab.tar.gz'
  $gitlab_secret_file = 'gitlab-secrets.json'

  # Concerning the "tar-gitlab-backup" file.
  $suffix_tar_file    = '_gitlab_backup.tar'
  #
  # Since Gitlab 9.0.0 at least (somewhere between 8.14.4
  # and 9.0.0), the pattern of a backup file is:
  #
  #   1490713606_2017_03_08_gitlab_backup.tar
  #
  # no longer:
  #
  #   1490713606_gitlab_backup.tar
  #
  $regex_tar_file     = "[0-9]+_[0-9]{4}_[0-9]{2}_[0-9]{2}${suffix_tar_file}"
  $pattern_tar_file   = "*${suffix_tar_file}"

}



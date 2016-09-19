class gitlab::params (
  Pattern[/^https?:\/\//] $external_url,
  Gitlab::LdapConf        $ldap_conf,
  Integer[1]              $backup_retention,
  String                  $backup_cron_wrapper,
  Integer                 $backup_cron_hour,
  Integer                 $backup_cron_minute,
  String                  $ssl_cert,
  String                  $ssl_key,
  Array[String[1], 1]     $supported_distributions,
) {

  $gitlab_backup_dir  = '/var/opt/gitlab/backups'
  $local_backup_dir   = '/localbackup'
  $backup_cmd         = '/usr/local/sbin/gitlab-backup.puppet'
  $etcgitlab_targz    = 'etcgitlab.tar.gz'
  $gitlab_secret_file = 'gitlab-secrets.json'

  # Concerning the "tar-gitlab-backup" file.
  $suffix_tar_file    = '_gitlab_backup.tar'
  $regex_tar_file     = "[0-9]+${suffix_tar_file}"
  $pattern_tar_file   = "*${suffix_tar_file}"

}



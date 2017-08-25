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
  Optional[String[1]] $sign_in_regex,
  Optional[String[1]] $health_page_token,
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
  # Episode 1: since Gitlab 9.0.0 at least (somewhere
  # between 8.14.4 and 9.0.0), the pattern of a backup file
  # is:
  #
  #   1490713606_2017_03_08_gitlab_backup.tar
  #   (the date is added in the name)
  #
  # no longer:
  #
  #   1490713606_gitlab_backup.tar
  #
  # Episode 2: since Gitlab 9.2.2 at least (somewhere
  # between 9.1.4 and 9.2.2), the pattern of a backup file
  # is:
  #
  #   1496571675_2017_06_04_9.2.2_gitlab_backup.tar
  #   (the gitlab version is added in the name)
  #
  # no longer:
  #
  #   1496571675_2017_06_04_gitlab_backup.tar
  #
  $regex_tar_file     = "[0-9]+_[0-9]{4}_[0-9]{2}_[0-9]{2}_[0-9\.]+${suffix_tar_file}"
  $pattern_tar_file   = "*${suffix_tar_file}"

}



class gitlab::params (
  String[1]           $external_url,
  Gitlab::LdapConf    $ldap_conf,
  Integer[1]          $backup_retention,
  String              $backup_cron_wrapper,
  Integer             $backup_cron_hour,
  Integer             $backup_cron_minute,
  Array[String[1], 1] $supported_distributions,
) {

  $gitlabbackupdir = '/var/opt/gitlab/backups'
  $localbackupdir  = '/localbackup'
  $backupcmd       = '/usr/local/sbin/backup-gitlab.puppet'

}



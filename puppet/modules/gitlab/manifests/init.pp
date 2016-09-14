class gitlab {

  include '::gitlab::params'

  [
    $external_url,
    $ldap_conf,
    $backup_retention,
    $backup_cron_wrapper,
    $backup_cron_hour,
    $backup_cron_minute,
    $supported_distributions,
    # In the params class but not as parameter.
    $gitlab_backup_dir,
    $local_backup_dir,
    $backup_cmd,
    $etcgitlab_targz,
    $suffix_tar_file,
    $regex_tar_file,
    $pattern_tar_file,
    $gitlab_secret_file,
  ] = Class['::gitlab::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  ensure_packages(['gitlab-ce'], { ensure => present })

  exec { 'save-default-gitlab.rb':
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    command => 'cp -a /etc/gitlab/gitlab.rb /etc/gitlab/gitlab.rb.origin',
    user    => 'root',
    group   => 'root',
    unless  => 'test -f /etc/gitlab/gitlab.rb.origin',
    require => Package['gitlab-ce'],
  }

  file { '/etc/gitlab/gitlab.rb':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    require => Exec['save-default-gitlab.rb'],
    notify  => Exec['gitlab-ctl-reconfigure'],
    content => epp( 'gitlab/gitlab.rb.epp',
                    {
                      'external_url' => $external_url,
                      'ldap_conf'    => $ldap_conf,
                    },
                  ),
  }

  exec { 'gitlab-ctl-reconfigure':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'gitlab-ctl reconfigure',
    user        => 'root',
    group       => 'root',
    refreshonly => true,
    require     => File['/etc/gitlab/gitlab.rb'],
  }

  file { $local_backup_dir:
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => Exec['gitlab-ctl-reconfigure'],
  }

  file { $backup_cmd:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => File[$local_backup_dir],
    content => epp( 'gitlab/gitlab-backup.puppet.epp',
                    {
                      'gitlab_backup_dir' => $gitlab_backup_dir,
                      'local_backup_dir'  => $local_backup_dir,
                      'backup_retention'  => $backup_retention,
                      'etcgitlab_targz'   => $etcgitlab_targz,
                      'regex_tar_file'    => $regex_tar_file,
                      'pattern_tar_file'  => $pattern_tar_file,
                    }
                  ),
  }

  cron { 'backup-gitlab-cron':
    ensure  => present,
    user    => 'root',
    command => [$backup_cron_wrapper, "${backup_cmd} >/dev/null"].join(' '),
    hour    => $backup_cron_hour,
    minute  => $backup_cron_minute,
    weekday => '*',
    require => File[$backup_cmd],
  }

  file { '/usr/local/sbin/gitlab-restore.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    require => Cron['backup-gitlab-cron'],
    content => epp( 'gitlab/gitlab-restore.puppet.epp',
                    {
                      'gitlab_backup_dir'  => $gitlab_backup_dir,
                      'local_backup_dir'   => $local_backup_dir,
                      'suffix_tar_file'    => $suffix_tar_file,
                      'regex_tar_file'     => $regex_tar_file,
                      'etcgitlab_targz'    => $etcgitlab_targz,
                      'gitlab_secret_file' => $gitlab_secret_file,
                    }
                  ),
  }

}



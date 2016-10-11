class gitlab {

  include '::gitlab::params'

  [
    $external_url,
    $ldap_conf,
    $custom_nginx_config,
    $backup_retention,
    $backup_cron_wrapper,
    $backup_cron_hour,
    $backup_cron_minute,
    $ssl_cert,
    $ssl_key,
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

  # Check that $ssl_cert and $ssl_key are not empty if
  # the external url is a https url. And we set the $ssl
  # boolean.
  if $external_url =~ /^https/ {

    $ssl        = true
    $ssl_ensure = 'present'

    if $ssl_cert.empty or $ssl_key.empty {
      @("END"/L$).fail
        Class ${title}: the external url is a https url but one of the \
        two parameters `\${ssl_key}` or `\${ssl_cert}` is empty which is \
        not allowed.
        |-END
    }

  } else {

    $ssl        = false
    $ssl_ensure = 'absent'

  }

  # The fqdn without the 'https://' or 'http://' part.
  $fqdn_cert = $external_url.regsubst('^https?://', '').regsubst('/.*$', '')


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
    notify  => Exec['gitlab-ctl-reconfigure-restart'],
    content => epp( 'gitlab/gitlab.rb.epp',
                    {
                      'external_url'        => $external_url,
                      'ssl'                 => $ssl,
                      'ldap_conf'           => $ldap_conf,
                      'custom_nginx_config' => $custom_nginx_config,
                    },
                  ),
  }

  file { '/etc/gitlab/ssl':
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0700',
    require => File['/etc/gitlab/gitlab.rb'],
    notify  => Exec['gitlab-ctl-reconfigure-restart'],
  }

  file { "/etc/gitlab/ssl/${fqdn_cert}.crt":
    ensure  => $ssl_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $ssl_cert,
    require => File['/etc/gitlab/gitlab.rb'],
    notify  => Exec['gitlab-ctl-reconfigure-restart'],
  }

  file { "/etc/gitlab/ssl/${fqdn_cert}.key":
    ensure  => $ssl_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0600',
    content => $ssl_key,
    require => File['/etc/gitlab/gitlab.rb'],
    notify  => Exec['gitlab-ctl-reconfigure-restart'],
  }

  $ensure_nginx_custom_conf = $custom_nginx_config.empty ? {
    true  => 'absent',
    false => 'present'
  }

  file { '/etc/gitlab/nginx-custom.conf':
    ensure  => $ensure_nginx_custom_conf,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp( 'gitlab/nginx-custom.conf.epp',
                    {
                      'custom_nginx_config' => $custom_nginx_config,
                    },
                  ),
    require => File['/etc/gitlab/gitlab.rb'],
    notify  => Exec['gitlab-ctl-reconfigure-restart'],
  }

  exec { 'gitlab-ctl-reconfigure-restart':
    path        => '/usr/sbin:/usr/bin:/sbin:/bin',
    command     => 'gitlab-ctl reconfigure && sleep 2 && gitlab-ctl restart',
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
    require => Exec['gitlab-ctl-reconfigure-restart'],
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



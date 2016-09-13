class gitlab {

  include '::gitlab::params'

  [
    $external_url,
    $ldap_conf,
    $supported_distributions,
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

  file { '/usr/local/sbin/backup-gitlab':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    content => epp( 'gitlab/backup-gitlab.epp', {} ),
  }

}



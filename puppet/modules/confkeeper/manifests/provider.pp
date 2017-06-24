class confkeeper::provider {

  include '::confkeeper::provider::params'

  [
    $collection,
    $supported_distributions,
    #
    $etckeeper_sshkey_path,
    $etckeeper_known_hosts,
  ] = Class['::confkeeper::provider::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $fqdn = $::facts['networking']['fqdn']

  exec { 'create-ssh-keys-for-etckeeper':
    creates   => "${etckeeper_sshkey_path}.pub",
    command   => "ssh-keygen -b 4096 -t rsa -C 'root@${fqdn}' -P '' -f '${etckeeper_sshkey_path}'",
    user      => 'root',
    group     => 'root',
    path      => '/usr/bin:/bin',
    cwd       => '/root',
    logoutput => 'on_failure',
    require   => File['/home/gitolite-admin'],
  }

  case $::facts['os']['distro']['codename'] {
    'trusty': {
      file { '/usr/local/bin/etckeeper_git_ssh':
        ensure  => file,
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        require => Exec['create-ssh-keys-for-etckeeper'],
        content => epp('confkeeper/provider/mv-old-repos.epp',
                       {
                         'etckeeper_sshkey_path' => $etckeeper_sshkey_path,
                         'etckeeper_known_hosts' => $etckeeper_known_hosts,
                       }
                   ),
      }

      $git_ssh_envvars = ['GIT_SSH=/usr/local/bin/etckeeper_git_ssh']
    }

    default: {
      $git_ssh_envvars = ["GIT_SSH_COMMAND='ssh -i ~/.ssh/etckeeper_id_rsa'"]
    }
  }

  #ensure_packages(['gitolite3'], { ensure => present })

}



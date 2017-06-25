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
  }

  Sshkey <<| tag == $collection |>> {
    require => Exec['create-ssh-keys-for-etckeeper'],
  }

  @@confkeeper::provider::repos { "${fqdn}_default_repos":
    etckeeper_ssh_pubkey => $::facts['etckeeper_ssh_pubkey'],
    directories          => ['/etc'],
    tag                  => $collection,
  }

  case $::facts['os']['distro']['codename'] {

    'trusty': {

      # With Git version < 2.0 (which is the case on
      # Trusty), the environment variable GIT_SSH_COMMAND is
      # not available. So we have to use the environment
      # variable GIT_SSH and we have provide a Git ssh
      # wrapper script.

      file { '/usr/local/bin/etckeeper_git_ssh':
        ensure  => file,
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        require => Exec['create-ssh-keys-for-etckeeper'],
        content => epp('confkeeper/provider/etckeeper_git_ssh.epp',
                       {
                         'etckeeper_sshkey_path' => $etckeeper_sshkey_path,
                         'etckeeper_known_hosts' => $etckeeper_known_hosts,
                       }
                   ),
      }

      $git_ssh_envvars = ['GIT_SSH=/usr/local/bin/etckeeper_git_ssh']

    }

    default: {

      # With Git version > 2.0, we can use the environment
      # variable GIT_SSH_COMMAND and it's not necessary to
      # create a dedicated wrapper script.
      $git_ssh_envvars = ["GIT_SSH_COMMAND='ssh -o 'UserKnownHostsFile=${etckeeper_known_hosts}' -i '${etckeeper_sshkey_path}'"]

    }
  }

  #ensure_packages(['gitolite3'], { ensure => present })

}



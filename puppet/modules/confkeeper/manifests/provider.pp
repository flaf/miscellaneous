class confkeeper::provider {

  include '::confkeeper::provider::params'

  [
    $collection,
    $repositories,
    $supported_distributions,
    #
    $etckeeper_sshkey_path,
    $etckeeper_known_hosts,
  ] = Class['::confkeeper::provider::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  $fqdn = $::facts['networking']['fqdn']

  $puppetdb_query = @(END)
    resources[parameters]{
      type = 'Class' and title = 'Confkeeper::Collector::Params'
    }
    |-END

  $collectors_params = puppetdb_query($puppetdb_query)

  if $collectors_params.empty {
    @("END"/L$).fail
      Class ${title}: no class `Confkeeper::Collector::params` retrieved \
      via Puppetdb. It seems that no confkeeper collector has been \
      installed yet. To install a confkeeper provider, you have to \
      install a confkeeper collector first.
      |-END
  }

  $candidate_collectors_params = $collectors_params.filter |$a_collector| {
    $a_collector['parameters']['collection'] == $collection
  }

  if $candidate_collectors_params.empty {
    @("END"/L$).fail
      Class ${title}: some classes `Confkeeper::Collector::params` has \
       been retrieved via Puppetdb but none has the collection parameter \
       equal to `${collection}`. This current confkeeper provider is \
       currently "collectorless".
      |-END
  }

  if $candidate_collectors_params.length > 1  {
    @("END"/L$).fail
      Class ${title}: multiple classes `Confkeeper::Collector::params` which \
      belong to the collection `${collection}` has been retrieved via \
      Puppetdb but a confkeeper provider must have only one confkeeper \
      collector.
      |-END
  }

  $collector_params          = $candidate_collectors_params[0]['parameters']
  $collector_address         = $collector_params['address']
  $collector_ssh_host_pubkey = $collector_params['ssh_host_pubkey']

  if $collector_ssh_host_pubkey =~ Undef {
    @("END"/L$).fail
      Class ${title}: a unique class `Confkeeper::Collector::params` which \
      belongs to the collection `${collection}` has been retrieved via \
      Puppetdb but its parameter `ssh_host_pubkey` is undef. A confkeeper \
      provider must know the RSA ssh host public key of its collector.
      |-END
  }

  sshkey {'collector-sshkey-for-provider':
    name   => $collector_address,
    ensure => present,
    key    => $collector_ssh_host_pubkey,
    type   => 'ssh-rsa',
    target => $etckeeper_known_hosts,
  }

  exec { 'create-ssh-keys-for-etckeeper':
    creates   => "${etckeeper_sshkey_path}.pub",
    command   => @("END"/L$),
      ssh-keygen -b 4096 -t rsa -C "root@${fqdn}" -P "" \
      -f "${etckeeper_sshkey_path}"
      |-END
    user      => 'root',
    group     => 'root',
    path      => '/usr/bin:/bin',
    cwd       => '/root',
    logoutput => 'on_failure',
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

    } # "trusty" case.

    default: {

      # With Git version > 2.0, we can use the environment
      # variable GIT_SSH_COMMAND and it's not necessary to
      # create a dedicated wrapper script.
      $git_ssh_command = @("END"/L$)
        ssh -o UserKnownHostsFile="${etckeeper_known_hosts}" \
        -i "${etckeeper_sshkey_path}"
      |-END
      $git_ssh_envvars = ["GIT_SSH_COMMAND='${git_ssh_command}'"]

    }
  } # "default" case.

  #ensure_packages(['gitolite3'], { ensure => present })

}



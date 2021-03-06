class confkeeper::provider {

  include '::confkeeper::provider::params'

  [
    $collection,
    $repositories,
    $wrapper_cron,
    $hour_range_cron,
    $devnull_cron,
    $fqdn,
    $supported_distributions,
    #
    $etckeeper_sshkey_path,
    $etckeeper_known_hosts,
  ] = Class['::confkeeper::provider::params']

  ::homemade::is_supported_distrib($supported_distributions, $title)

  with($hour_range_cron) |$range| {
    $min = $range[0]
    $max = $range[1]
    unless $min < $max {
      @("END"/L$).fail
        Class ${title}: the `hour_range_cron` parameter of the `params` class \
        is not correct because the first element must be strictly lower than \
        the second.
        |-END
    }
  }

  $repositories_completed = ::confkeeper::complete_repos_settings(
    $repositories,
    'root',
    $fqdn,
  )

  $distribution = $::facts['os']['distro']['codename']

  $puppetdb_query = @("END")
    resources[parameters]{
      type = "Class" and title = "Confkeeper::Collector::Params"
        and parameters.collection = "${collection}"
        and nodes { deactivated is null and expired is null }
    }
    |-END

  $collectors_params = puppetdb_query($puppetdb_query)

  if $collectors_params.length == 0 {
    @("END"/L$).fail
      Class ${title}: no resource Class['Confkeeper::Collector::Params'] \
      with the `collection` parameter equal to "${collection}" has been \
      retrieved in Puppetdb. The current node seems to be collector-less. \
      To install a confkeeper provider, you have to install a confkeeper \
      collector in the same collection first.
      |-END
  }

  if $collectors_params.length > 1  {
    @("END"/L$).fail
      Class ${title}: multiple resources Class['Confkeeper::Collector::Params'] \
      with the `colleciton` parameter equal to "${collection}" have been \
      retrieved in Puppetdb but a confkeeper provider must have only one \
      confkeeper collector.
      |-END
  }

  $collector_params          = $collectors_params[0]['parameters']
  $collector_address         = $collector_params['address']
  $collector_ssh_host_pubkey = $collector_params['ssh_host_pubkey']

  if $collector_ssh_host_pubkey =~ Undef {
    @("END"/L$).fail
      Class ${title}: a unique resource Class['Confkeeper::Collector::Params'] \
      with the `collection` parameter equal to "${collection}" has been \
      retrieved in Puppetdb but its parameter `ssh_host_pubkey` is undef. A \
      confkeeper provider must know the RSA ssh host public key of its collector.
      |-END
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

  sshkey {'collector-sshkey-for-provider':
    name    => $collector_address,
    ensure  => present,
    key     => $collector_ssh_host_pubkey,
    type    => 'ssh-rsa',
    target  => $etckeeper_known_hosts,
    require => Exec['create-ssh-keys-for-etckeeper'],
    before  => Package['etckeeper'],
  }

  case $distribution {

    /^(trusty|jessie)/: {

      # With Git version < 2.3 (which is the case on
      # Trusty and Jessie), the environment variable
      # GIT_SSH_COMMAND is not available. So we have to use
      # the environment variable GIT_SSH and we have provide
      # a Git ssh wrapper script.

      file { '/usr/local/bin/etckeeper_git_ssh':
        ensure  => file,
        mode    => '0755',
        owner   => 'root',
        group   => 'root',
        require => Exec['create-ssh-keys-for-etckeeper'],
        before  => Package['etckeeper'],
        content => epp('confkeeper/provider/etckeeper_git_ssh.epp',
                       {
                         'etckeeper_sshkey_path' => $etckeeper_sshkey_path,
                         'etckeeper_known_hosts' => $etckeeper_known_hosts,
                       }
                   ),
      }

      $git_ssh_envvars = [
                          "GIT_SSH='/usr/local/bin/etckeeper_git_ssh'",
                          "GIT_AUTHOR_NAME='root'",
                          "GIT_AUTHOR_EMAIL='root@${fqdn}'",
                         ]

    } # "trusty" and "jessie" case.

    default: {

      # With Git version > 2.0, we can use the environment
      # variable GIT_SSH_COMMAND and it's not necessary to
      # create a dedicated wrapper script.
      $git_ssh_command = @("END"/L$)
        ssh -o UserKnownHostsFile="${etckeeper_known_hosts}" \
        -i "${etckeeper_sshkey_path}"
        |-END
      $git_ssh_envvars = [
                          "GIT_SSH_COMMAND='${git_ssh_command}'",
                          "GIT_AUTHOR_NAME='root'",
                          "GIT_AUTHOR_EMAIL='root@${fqdn}'",
                         ]

    }
  } # "default" case.

  ensure_packages(['etckeeper', 'git'], { ensure => present })

  file { '/etc/etckeeper/etckeeper.conf':
    ensure  => file,
    mode    => '0644',
    owner   => 'root',
    group   => 'root',
    content => epp('confkeeper/provider/etckeeper.conf.epp', {}),
    require => Package['etckeeper'],
  }

  file { '/etc/apt/apt.conf.d/05etckeeper':
    ensure  => absent,
    require => Package['etckeeper'],
  }

  file { '/usr/local/sbin/etckeeper-push-all':
    ensure  => file,
    mode    => '0750',
    owner   => 'root',
    group   => 'root',
    content => epp('confkeeper/provider/etckeeper-push-all.epp',
                   {
                     'repositories'      => $repositories_completed,
                     'git_ssh_envvars'   => $git_ssh_envvars,
                     'collector_address' => $collector_address,
                   }
               ),
    require => Package['etckeeper'],
  }

  # Initialization of the repositories.
  $repositories_completed.each |$localdir, $settings| {

    unless $settings['gitignore'] =~ Undef {
      file { "${localdir}/.gitignore":
        ensure  => file,
        mode    => '0644',
        owner   => 'root',
        group   => 'root',
        content => epp('confkeeper/provider/gitignore.epp',
                       {
                        'lines' => $settings['gitignore'],
                       }
                   ),
        before  => Exec["etckeeper-init-of-${localdir}"],
      }
    }

    exec { "etckeeper-init-of-${localdir}":
      creates   => "${localdir}/.git",
      command   => @("END"/L$),
        rm -rf --one-file-system "${localdir}/.bzr" && \
        rm -f "${localdir}/.bzrignore" && \
        etckeeper init -d "${localdir}"
        |-END
      user      => 'root',
      group     => 'root',
      path      => '/usr/bin:/bin',
      cwd       => '/root',
      logoutput => 'on_failure',
      require   => File['/etc/etckeeper/etckeeper.conf'],
    }

  } # End: initialization of the repositories.

  $cmd_push_all = '/usr/local/sbin/etckeeper-push-all'

  $cron_cmd = case [$wrapper_cron, $devnull_cron] {
    [Undef, false]:  { "${cmd_push_all}"                                 }
    [Undef, true]:   { "${cmd_push_all} >/dev/null 2>&1"                 }
    [String, false]: { "${wrapper_cron} ${cmd_push_all}"                 }
    [String, true]:  { "${wrapper_cron} ${cmd_push_all} >/dev/null 2>&1" }
  }

  $seed = 'etckeeper-push-all'

  $cron_hour = with($hour_range_cron) |$range| {
    $min = $range[0]
    $max = $range[1]
    $min + fqdn_rand($max-$min, $seed)
  }

  cron { 'etckeeper-push-all':
    ensure   => present,
    user     => 'root',
    command  => $cron_cmd,
    hour     => $cron_hour,
    minute   => fqdn_rand(60, $seed),     # from 0 to 59
    monthday => absent,                   # ie *
    month    => absent,                   # ie *
    weekday  => absent,                   # ie *
    require  => File['/usr/local/sbin/etckeeper-push-all'],
  }

}



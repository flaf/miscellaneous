class puppetserver::puppetconf {

  # /!\ Warning /!\
  #
  # If the puppetserver host has the "autonomous" profile,
  # During a puppet run, its puppet agent (ie the client)
  # will communicate with its hosted puppetserver (the
  # server). In this case, it's complicated to restart the
  # puppetserver service during a puppet run because, in
  # this case, the puppet client can't talk with the service
  # which is restarting. Generally, we have an error during
  # the puppet run like this:
  #
  #   Error: Could not send report: Connection refused - connect(2)
  #   for "puppet4.dom.tld" port 8140
  #
  # It's logical. So, in this class there is no refresh of
  # the puppetserver service in the case where the node has
  # the "autonomus" profile. If you notice changes during
  # the puppet run, you should restart yourself the
  # puppetserver service.
  #
  # Remark: according to binford2k and WhatsARanjit (IRC),
  # this error is not a problem because "After the catalog
  # is compiled, most of the puppetserver's work is done. It
  # can be restarted during the agent run. puppet:/// file
  # requests will fail, the report might not send properly
  # at the end, but it totally works".

  include '::puppetserver::params'

  [
    $profile,
    $puppet_memory,
    $modules_repository,
    $http_proxy,
    $strict,
    $strict_variables,
    $environments,
    $max_groups,
    $datacenters,
    # In the params class but not as parameter.
    $puppetlabs_path,
    $puppet_path,
    $puppet_conf,
    $ssldir,
    $puppet_bin_dir,
  ] = Class['::puppetserver::params']

  if $profile == 'autonomous' {
    $notify_puppetserver = undef
  } else {
    # So $profile == client.
    $notify_puppetserver = Service['puppetserver']
  }

  # git is present to be able to change modules directly in
  # the puppetserver. jq is present to be able read and
  # parse json in some scripts. puppetdb-termini is a
  # package needed when a puppetserver want to contact a
  # puppetdb server (installed in the same server or not).
  # This package is needed to make puppetserver able to
  # communicate with a puppetdb server. In our case, this
  # package is necessary for a "autonomous" _and_ a "client"
  # puppetserver (a "client" puppetserver doesn't host a
  # puppetdb server but must be able to talk with a puppetdb
  # server, so the package puppetdb-termini must be
  # installed in a "client" puppetserver too).
  ensure_packages( ['puppetserver', 'puppetdb-termini', 'git', 'jq'],
                   { ensure => present, }
                 )

  # Set the memory for the JVM which runs the puppetserver.
  $java_args ="-Xms${puppet_memory} -Xmx${puppet_memory} -XX:MaxPermSize=256m"

  file_line { 'set-memory-to-puppetserver-jvm':
    path   => '/etc/default/puppetserver',
    line   => "JAVA_ARGS=\"${java_args}\" # line edited by Puppet.",
    match  => '^JAVA_ARGS=.*$',
    before => Service['puppetserver'],
    notify => $notify_puppetserver,
  }

  # The environment directories and its sub-directories etc.
  $code_path         = "${puppetlabs_path}/code"
  $environment_path  = "${code_path}/environments"
  $keys_path         = "${puppet_path}/keys"
  $eyaml_public_key  = "${keys_path}/public_key.pkcs7.pem"
  $eyaml_private_key = "${keys_path}/private_key.pkcs7.pem"

  file {$environment_path:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    before => Service['puppetserver'],
    notify => $notify_puppetserver,
  }

  # Environments loop.
  $environments.each |$an_env| {

    $an_env_path    = "${environment_path}/${an_env}"
    $manifests_path = "${an_env_path}/manifests"
    $modules_path   = "${an_env_path}/modules"

    file {
      default:
        owner  => 'root',
        group  => 'root',
        before => Service['puppetserver'],
      ;

      [$an_env_path, $manifests_path, $modules_path]:
        ensure => 'directory',
        mode   => '0755',
        notify => $notify_puppetserver,
      ;

      # The environment.conf file must be present but its
      # content will not be managed (and will probably not
      # used).
      "${an_env_path}/environment.conf":
        ensure => present,
        mode   => '0644',
        notify => $notify_puppetserver,
      ;

      # The site.pp file.
      "${manifests_path}/site.pp":
        ensure => present,
        mode   => '0644',
        source => 'puppet:///modules/puppetserver/site.pp',
        # No need to restart the puppetserver here.
      ;

      # The hiera.yaml from the environment layer.
      "${an_env_path}/hiera.yaml":
        ensure  => present,
        mode    => '0644',
        notify  => $notify_puppetserver,
        content => epp(
                     'puppetserver/hiera.yaml.epp',
                     {
                       'max_groups'   => $max_groups,
                       'global_layer' => false,
                       'layer_title'  => "${an_env} environment layer",
                     }
                   ),
      ;
    }

  } # End of environments loop.

  file {
    default:
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0750',
      before  => Service['puppetserver'],
      # No need to restart the puppetserver here.
    ;

    '/usr/local/sbin/clean-node-crl-not-changed.puppet':
      content => epp(
                   'puppetserver/clean-node-crl-not-changed.puppet.epp',
                   {
                     'ssldir'         => $ssldir,
                     'puppet_bin_dir' => $puppet_bin_dir,
                   }
                 ),
    ;

    # Deprecated: should support the environment as argument
    # and this is not the case currently. Furthermore this
    # script is rarely used.
    #
    #'/usr/local/sbin/install-modules.puppet':
    #  content => epp(
    #               'puppetserver/install-modules.puppet.epp',
    #               {
    #                 'environment_path' => $environment_path,
    #                 'puppet_bin_dir'   => $puppet_bin_dir,
    #                 'modules_versions' => $modules_versions,
    #               }
    #             ),
    #;
    #
    #'/usr/local/sbin/update-modules.puppet':
    #  content => epp(
    #               'puppetserver/update-modules.puppet.epp',
    #               {
    #                 'modules_path'     => $modules_path, #### TODO: Problem here. This variable no longer exist.
    #                 'puppet_bin_dir'   => $puppet_bin_dir,
    #                 'modules_versions' => $modules_versions,
    #               }
    #             ),
    #;

    '/usr/local/sbin/check-puppet-module.puppet':
      content => epp(
                   'puppetserver/check-puppet-module.puppet.epp',
                   {
                     'puppet_bin_dir' => $puppet_bin_dir,
                   }
                 ),
    ;

  }

  # Deprecated: With Hiera 5, the correct way to share data
  # between the "autonomous" server and the "client" servers
  # is to use the hiera global layer.
  #
  #  # The "hieradata-common-from-master.yaml" file (ie the cfm
  #  # file) from the master present only when the puppetserver
  #  # has the "client" profile, not when it has the
  #  # "autonomous" profile.
  #  # We have exactly the same thing with the file
  #  # "hieradata-datacenter-from-master.yaml".
  #  # The "client" puppetserver will retrieve too some yaml
  #  # group files from the master via the $groups_from_master
  #  # variable.
  #  if $profile == 'client' {
  #
  #    # file() takes the content from the master puppet.
  #    # So the file must exist in the master.
  #    $cfm_content = file("${production_path}/hieradata/common.yaml")
  #    file { "${production_path}/hieradata-common-from-master.yaml":
  #      ensure  => present,
  #      owner   => 'root',
  #      group   => 'root',
  #      mode    => '0644',
  #      content => $cfm_content,
  #      before  => Service['puppetserver'],
  #      # No need to restart the puppetserver here.
  #    }
  #
  #    # Only if $::datacenter is defined for this server.
  #    if $::datacenter {
  #      $dfm_content = file("${production_path}/hieradata/datacenter/${::datacenter}.yaml")
  #      file { "${production_path}/hieradata-datacenter-${::datacenter}-from-master.yaml":
  #        ensure  => present,
  #        owner   => 'root',
  #        group   => 'root',
  #        mode    => '0644',
  #        content => $dfm_content,
  #        before  => Service['puppetserver'],
  #        # No need to restart the puppetserver here.
  #      }
  #    }
  #
  #    # The root directory. But maybe another directories must
  #    # be created. For instance, if the 'foo/mysql' hiera
  #    # group belongs to the array $groups_from_master, we
  #    # have to create the directory "$gfm_dir/foo" too, etc.
  #    $gfm_root = "${production_path}/hieradata-group-from-master"
  #
  #    # All the directories which must be created before to
  #    # create yaml-group files from the master below.
  #    $gfm_dirs = $groups_from_master.reduce([$gfm_root]) |$memo, $a_group| {
  #      $dir = dirname("${gfm_root}/${a_group}.yaml")
  #      case $dir in $memo {
  #        true:  { $memo          }
  #        false: { $memo + [$dir] }
  #      }
  #    }
  #
  #    # The "hieradata-group-from-master" directories and its files below.
  #    file { $gfm_dirs:
  #      ensure  => directory,
  #      owner   => 'root',
  #      group   => 'root',
  #      mode    => '0755',
  #      recurse => true,
  #      purge   => true,
  #      force   => true,
  #      before  => Service['puppetserver'],
  #      # No need to restart the puppetserver here.
  #    }
  #
  #    $groups_from_master.each |$a_group| {
  #      file { "${gfm_root}/${a_group}.yaml":
  #        ensure  => present,
  #        owner   => 'root',
  #        group   => 'root',
  #        mode    => '0644',
  #        content => file("${production_path}/hieradata/group/${a_group}.yaml"),
  #        before  => Service['puppetserver'],
  #        # No need to restart the puppetserver here.
  #      }
  #    }
  #
  #  } # End of "client" profile specific.

  # The hiera.yaml file. This file must trigger a restart
  # of the server when it is updated.
  file { "${code_path}/hiera.yaml":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Service['puppetserver'],
    notify  => $notify_puppetserver,
    content => epp('puppetserver/hiera.yaml.epp',
                   {
                     'max_groups'   => $max_groups,
                     'global_layer' => true,
                     'layer_title'  => "global layer",
                   }
                  ),
  }

  # The ENC script.
  file { "${environment_path}/enc":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => epp('puppetserver/enc.epp',
                   {
                    'max_groups'  => $max_groups,
                    'profile'     => $profile,
                    'datacenters' => $datacenters,
                   }
                  ),
    before  => Service['puppetserver'],
    # No need to restart the puppetserver here.
  }

  # The puppetdb.conf file. This file explains to Puppet how to
  # contact the puppetdb. You must use a http*s* connection, so
  # the localhost address is impossible (because puppetdb doesn't
  # use ssl on localhost) and you must provide a fqdn for the
  # address.
  if $profile == 'autonomous' {
    # The puppetdb is the server itself.
    $puppetdb_fqdn = $::fqdn
  } else {
    # The puppetserver is a client of its master which is
    # the puppetdb.
    $puppetdb_fqdn = $::server_facts['servername']
  }

  file { "$puppet_path/puppetdb.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Service['puppetserver'],
    notify  => $notify_puppetserver,
    content => epp('puppetserver/puppetdb.conf.epp',
                   { 'puppetdb_fqdn' => $puppetdb_fqdn, }
                  ),
  }

  file { "$puppet_path/routes.yaml":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/puppetserver/routes.yaml',
    before => Service['puppetserver'],
    notify => $notify_puppetserver,
  }

  # In the case of a 'client' puppetserver, it must have a
  # copy of the CRL of the Puppet CA. It's very important to
  # propagate the CRL of the CA to all 'client' puppetserver.
  # So we need to redefine the cacrl parameter in puppet.conf.
  if $profile == 'client' {
    file { "${ssldir}/ca_crl.pem":
      ensure  => present,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0644',
      # The content of this file must be the same
      # as the content of the CRL of the Puppet CA,
      # ie the master of the current puppetserver.
      content => file("${ssldir}/ca/ca_crl.pem"),
      before  => Service['puppetserver'],
      # Really important to restart the puppetserver
      # in this case.
      notify  => $notify_puppetserver,
    }
  }

  case $http_proxy {
    Undef: {
      $http_proxy_host           = undef
      $http_proxy_port           = undef
      $http_proxy_in_puppet_conf = false
      $gem_server_options        = '--no-ri --no-rdoc'
      $gem_options               = ''
    }
    default: {
      $http_proxy_host           = $http_proxy['host']
      $http_proxy_port           = $http_proxy['port']
      $http_proxy_in_puppet_conf = $http_proxy['in_puppet_conf']
      $gem_server_options        = "--no-ri --no-rdoc --http_proxy http://${http_proxy_host}:${http_proxy_port}"
      $gem_options               = "--http_proxy http://${http_proxy_host}:${http_proxy_port}"
    }
  }

  file { $puppet_conf:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Service['puppetserver'],
    notify  => $notify_puppetserver,
    content => epp('puppetserver/puppet.conf.epp',
                   { 'profile'                   => $profile,
                     'modules_repository'        => $modules_repository,
                     'strict'                    => $strict,
                     'strict_variables'          => $strict_variables,
                     'http_proxy_in_puppet_conf' => $http_proxy_in_puppet_conf,
                     'http_proxy_host'           => $http_proxy_host,
                     'http_proxy_port'           => $http_proxy_port,
                   }
                  ),
  }

  # Installation of eyaml and deep_merge.
  file { "${puppet_path}/keys":
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0755',
    notify => $notify_puppetserver,
    before => [
                Exec['install-gem-hiera-eyaml'],
                Exec['install-gem-deep-merge'],
                Exec['install-gem-hiera-eyaml-for-user'],
                Exec['install-gem-deep-merge-for-user'],
                Service['puppetserver'],
              ],
  }

  $ppsrv_bin = '/opt/puppetlabs/bin/puppetserver'
  $eyaml_bin = '/opt/puppetlabs/server/data/puppetserver/jruby-gems/bin/eyaml'
  $data_dir  = '/opt/puppetlabs/server/data/puppetserver'

  exec { 'install-gem-hiera-eyaml':
    command => "${ppsrv_bin} gem install hiera-eyaml ${gem_server_options}",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "test -e '${eyaml_bin}'",
    before  => Service['puppetserver'],
    notify  => $notify_puppetserver,
  }

  exec { 'install-gem-deep-merge':
    command => "${ppsrv_bin} gem install deep_merge ${gem_server_options}",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "find ${data_dir} -type f -name 'deep_merge.rb' | grep -Eq '.'",
    before  => Service['puppetserver'],
    notify  => $notify_puppetserver,
  }

  # Above the installation for puppetserver with Jruby.
  # But we must install the gems for users too. I think
  # it's the same program and only the interpretor changes
  # (jruby versus ruby).
  # TODO: I thought that a user could take the gem from the
  # puppetserver but I have not found the way to do that.
  exec { 'install-gem-hiera-eyaml-for-user':
    command => "/opt/puppetlabs/puppet/bin/gem install hiera-eyaml ${gem_options}",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => '/opt/puppetlabs/puppet/bin/gem list | grep -q "^hiera-eyaml "',
    before  => Service['puppetserver'],
    # No need to restart the puppetserver here.
  }

  exec { 'install-gem-deep-merge-for-user':
    command => "/opt/puppetlabs/puppet/bin/gem install deep_merge ${gem_options}",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => '/opt/puppetlabs/puppet/bin/gem list | grep -q "^deep_merge "',
    before  => Service['puppetserver'],
    # No need to restart the puppetserver here.
  }

  file { $eyaml_public_key:
    ensure  => present,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0400',
    content => file($eyaml_public_key),
    before  => Service['puppetserver'],
    notify  => $notify_puppetserver,
  }

  file { $eyaml_private_key:
    ensure  => present,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0400',
    content => file($eyaml_private_key),
    before  => Service['puppetserver'],
    notify  => $notify_puppetserver,
  }

  # If the puppetserver has the 'client' profile, we have to
  # disable the CA service which is, by default, automatically
  # launched at each start of the puppetserver service.
  if $profile == 'client' {

    $ca_cfg          = "${puppetlabs_path}/puppetserver/services.d/ca.cfg"
    $line_enable_ca  = 'puppetlabs.services.ca.certificate-authority-service/certificate-authority-service'
    $line_disable_ca = 'puppetlabs.services.ca.certificate-authority-disabled-service/certificate-authority-disabled-service'

    file_line { 'comment-line-enable-CA-service':
      path    => $ca_cfg,
      line    => "#${line_enable_ca} # Edited by Puppet.",
      match   => "^#?[[:space:]]*${line_enable_ca}[[:space:]]*.*$",
      before  => Service['puppetserver'],
      notify  => $notify_puppetserver,
    }

    file_line { 'uncomment-line-disable-CA-service':
      path    => $ca_cfg,
      line    => "${line_disable_ca} # Edited by Puppet.",
      match   => "^#?[[:space:]]*${line_disable_ca}[[:space:]]*.*$",
      before  => Service['puppetserver'],
      notify  => $notify_puppetserver,
    }
  }

  service { 'puppetserver':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }

  # TODO: We don't manage the content of this file but
  # just ensure the Unix rights to avoid something which
  # seems to be a bug for me:
  #
  #   https://tickets.puppetlabs.com/browse/SERVER-906
  #
  # Only if the node is an autonomous puppetserver, ie
  # a Puppet CA.
  if $profile == 'autonomous' {
    file { "${ssldir}/ca/ca_key.pem":
      ensure  => present,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0640',
      # Indeed, the file exists only once the puppetserver is started.
      require => Service['puppetserver'],
    }
  }

  $git_ssh_wrapper_content = @(END)
  #!/bin/bash

  ### This file is managed by Puppet, don't edit it. ###

  # Wrapper to allow several sudo unix accounts to edit the
  # same ssh repository (owned by root) with his owned ssh
  # private key.
  #
  # Just put this in your .bashrc:
  #
  #   export GIT_SSH=/usr/local/bin/git_ssh_wrapper
  #
  # And after a `sudo su -p`, you could edit the git
  # repository with your owned ssh private key.

  export PATH='/usr/sbin:/usr/bin:/sbin:/bin'

  ssh -i ~/.ssh/id_rsa "$1" "$2"

  | END

  file { '/usr/local/bin/git_ssh_wrapper':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '755',
    content => $git_ssh_wrapper_content,
  }

  file { '/usr/local/bin/create-puppet-module.puppet':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '755',
    content => epp(
                   'puppetserver/create-puppet-module.puppet.epp',
                    {
                     'puppet_bin_dir' => $puppet_bin_dir,
                     'puppet_conf'    => $puppet_conf,
                    }
               ),
  }

  # it's just a convenience.
  file { '/puppet':
    ensure => link,
    target => '/etc/puppetlabs/code/environments/production',
  }

}



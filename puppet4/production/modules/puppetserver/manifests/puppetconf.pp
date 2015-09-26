class puppetserver::puppetconf {

  # /!\ Warning /!\
  #
  # If the puppetserver host has the "autonomous" profile,
  # During a puppet run, its puppet agent (ie the client)
  # will communicate with its hosted puppetserver (the server).
  # In this case, it's complicated to restart the puppetserver
  # service during a puppet run because, in this case, the
  # puppet client can't talk with the service which is
  # restarting. Generally, we have an error during the puppet
  # run like this:
  #
  #   Error: Could not send report: Connection refused - connect(2)
  #   for "puppet4.dom.tld" port 8140
  #
  # It's logical. So, in this class there is no refresh of the
  # puppetserver service in the case where the node has the
  # "autonomus" profile.. If you notice changes during the puppet
  # run, you should restart yourself the puppetserver service.

  $profile                 = $::puppetserver::profile
  $memory                  = $::puppetserver::puppet_memory
  $modules_repository      = $::puppetserver::modules_repository
  $modules_versions        = $::puppetserver::modules_versions

  if $profile == 'autonomous' {
    $notify_puppetserver = undef
  } else {
    # So $profile == client.
    $notify_puppetserver = Service['puppetserver']
  }

  require '::repository::puppet'
  # git is to be able to change modules directly in the
  # puppetserver.
  ensure_packages( ['puppetserver', 'puppetdb-termini', 'git'],
                   { ensure => present, }
                 )

  # Set the memory for the JVM which runs the puppetserver.
  $java_args ="-Xms${memory} -Xmx${memory} -XX:MaxPermSize=256m"

  file_line { 'set-memory-to-puppetserver-jvm':
    path   => '/etc/default/puppetserver',
    line   => "JAVA_ARGS=\"${java_args}\" # line edited by Puppet.",
    match  => '^JAVA_ARGS=.*$',
    before => Service['puppetserver'],
    notify => $notify_puppetserver,
  }

  # The environment directories and its sub-directories etc.
  $puppetlabs_path   = '/etc/puppetlabs'
  $code_path         = "${puppetlabs_path}/code"
  $environment_path  = "${code_path}/environments"
  $production_path   = "${environment_path}/production"
  $manifests_path    = "${production_path}/manifests"
  $modules_path      = "${production_path}/modules"
  $puppet_path       = "${puppetlabs_path}/puppet"
  $ssldir            = "${puppet_path}/ssl"
  $keys_path         = "${puppet_path}/keys"
  $eyaml_public_key  = "${keys_path}/public_key.pkcs7.pem"
  $eyaml_private_key = "${keys_path}/private_key.pkcs7.pem"
  $puppet_bin_dir    = '/opt/puppetlabs/puppet/bin'

  file { [ $environment_path,
           $production_path,
           $manifests_path,
           $modules_path,
         ]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    before => Service['puppetserver'],
    notify => $notify_puppetserver,
  }

  # The environment.conf file must be present but its content
  # will not be managed (and will probably not used).
  file { "${production_path}/environment.conf":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    before => Service['puppetserver'],
    notify => $notify_puppetserver,
  }

  # The site.pp file.
  file { "${manifests_path}/site.pp":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    before => Service['puppetserver'],
    source => 'puppet:///modules/puppetserver/site.pp',
    # No need to restart the puppetserver here.
  }

  file { "/usr/local/sbin/install-modules.puppet":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0750',
    before  => Service['puppetserver'],
    content => epp('puppetserver/install-modules.puppet.epp',
                   {
                     'environment_path' => $environment_path,
                     'puppet_bin_dir'   => $puppet_bin_dir,
                     'modules_versions' => $modules_versions,
                   }
                  ),
    # No need to restart the puppetserver here.
  }

  # The "common-from-master.yaml" file (ie the cfm file)
  # from the master present only when the puppetserver
  # has the "client" profile, not when it has the "autonomous"
  # profile.
  if $profile == 'autonomous' {
    $cfm_ensure  = 'absent'
    $cfm_content = undef
  } else {
    # The puppetserver has the "client" profile.
    # file() takes the content from the master puppet.
    # So the file must exist in the master.
    $cfm_ensure  = 'present'
    $cfm_content = file("${production_path}/hieradata/common.yaml")
  }

  file { "${production_path}/common-from-master.yaml":
    ensure  => $cfm_ensure,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => $cfm_content,
    before  => Service['puppetserver'],
    # No need to restart the puppetserver here.
  }

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
                   { 'profile' => $profile }
                  ),
  }

  # The ENC script.
  file { "${environment_path}/enc":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/puppetserver/enc',
    before => Service['puppetserver'],
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

  file { "$puppet_path/puppet.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    before  => Service['puppetserver'],
    notify  => $notify_puppetserver,
    content => epp('puppetserver/puppet.conf.epp',
                   { 'profile'            => $profile,
                     'modules_repository' => $modules_repository,
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
    command => "${ppsrv_bin} gem install hiera-eyaml --no-ri --no-rdoc",
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "test -e '${eyaml_bin}'",
    before  => Service['puppetserver'],
    notify  => $notify_puppetserver,
  }

  exec { 'install-gem-deep-merge':
    command => "${ppsrv_bin} gem install deep_merge --no-ri --no-rdoc",
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
    command => '/opt/puppetlabs/puppet/bin/gem install hiera-eyaml',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => '/opt/puppetlabs/puppet/bin/gem list | grep -q "^hiera-eyaml "',
    before  => Service['puppetserver'],
    # No need to restart the puppetserver here.
  }

  exec { 'install-gem-deep-merge-for-user':
    command => '/opt/puppetlabs/puppet/bin/gem install deep_merge',
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

    # Be careful, break a long line of strings with backslash works only
    # with double quotes (ie "...") not with simple quotes (ie '...').
    $bootstrap_cfg   = "${puppetlabs_path}/puppetserver/bootstrap.cfg"
    $line_enable_ca  = "puppetlabs.services.ca.certificate-authority-\
service/certificate-authority-service"
    $line_disable_ca = "puppetlabs.services.ca.certificate-authority-\
disabled-service/certificate-authority-disabled-service"

    file_line { 'comment-line-enable-CA-service':
      path    => $bootstrap_cfg,
      line    => "#${line_enable_ca} # Edited by Puppet.",
      match   => "^#?[[:space:]]*${line_enable_ca}[[:space:]]*.*$",
      before  => Service['puppetserver'],
      notify  => $notify_puppetserver,
    }

    file_line { 'uncomment-line-disable-CA-service':
      path    => $bootstrap_cfg,
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

}



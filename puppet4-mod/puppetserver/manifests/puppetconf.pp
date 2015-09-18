class puppetserver::puppetconf {

  # /!\ Warning /!\
  # It complicated to restart the puppetserver service during
  # a puppet run because, in this case, the puppet client can't
  # talk with the service which is restarting. Generally, we
  # have a error during the puppet run like this:
  #
  #   Error: Could not send report: Connection refused - connect(2)
  #   for "puppet4.dom.tld" port 8140
  #
  # It's logical. So, in this class there is no refresh of the
  # puppetserver service. If you notice changes during the puppet
  # run, you should restart yourself the puppetserver service.

  $memory                  = $::puppetserver::puppet_memory
  $retrieve_common_hiera   = $::puppetserver::retrieve_common_hiera
  $puppetdb_fqdn           = $::puppetserver::puppetdb_fqdn
  $ca_server               = $::puppetserver::ca_server
  $puppet_server_for_agent = $::puppetserver::puppet_server_for_agent
  $module_repository       = $::puppetserver::module_repository
  $puppetdb_myself         = $::puppetserver::puppetdb_myself
  $ca_myself               = $::puppetserver::ca_myself
  $puppetserver_for_myself = $::puppetserver::puppetserver_for_myself

  require '::repository::puppet'
  ensure_packages(['puppetserver', 'puppetdb-termini'], { ensure => present, })

  # Set the memory for the JVM which runs the puppetserver.
  $java_args ="-Xms${memory} -Xmx${memory} -XX:MaxPermSize=256m"

  file_line { 'set-memory-to-puppetserver-jvm':
    path   => '/etc/default/puppetserver',
    line   => "JAVA_ARGS=\"${java_args}\" # line edited by Puppet.",
    match  => '^JAVA_ARGS=.*$',
  }

  service { 'puppetserver':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
    enable     => true,
  }

  # The environment directories and its sub-directories etc.
  $etc_path          = '/etc/puppetlabs'
  $code_path         = "${etc_path}/code"
  $environment_path  = "${code_path}/environments"
  $production_path   = "${environment_path}/production"
  $manifests_path    = "${production_path}/manifests"
  $modules_path      = "${production_path}/modules"
  $eyaml_public_key  = "${etc_path}/puppet/keys/public_key.pkcs7.pem"
  $eyaml_private_key = "${etc_path}/puppet/keys/private_key.pkcs7.pem"

  file { [ $environment_path,
           $production_path,
           $manifests_path,
           $modules_path,
         ]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # The environment.conf file must be present but its content
  # will not be managed (and will probably not used).
  file { "${production_path}/environment.conf":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
  }

  # The site.pp file.
  file { "${manifests_path}/site.pp":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/puppetserver/site.pp',
  }

  # The common.yaml file from the master.
  if $retrieve_common_hiera {
    $ensure_common = 'present'
  } else {
    $ensure_common = 'absent'
  }

  file { "${production_path}/common-from-master.yaml":
    ensure  => $ensure_common,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => file("${production_path}/hieradata/common.yaml"),
  }

  # The hiera.yaml file.
  file { "${code_path}/hiera.yaml":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('puppetserver/hiera.yaml.epp',
                   { 'retrieve_common_hiera' => $retrieve_common_hiera }
                  ),
  }

  # The ENC script.
  file { "${environment_path}/enc":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => 'puppet:///modules/puppetserver/enc',
  }

  # The puppetdb.conf. This file explains to Puppet how to
  # contact the puppetdb. You must use a https connection,
  # so the localhost address is impossible (because puppetdb
  # doesn't use ssl on localhost) and you must provide a
  # fqdn for the address.
  if $puppetdb_myself {
    $puppetdb_addr = $::fqdn
  } else {
    $puppetdb_addr = $puppetdb_fqdn
  }
  file { "$etc_path/puppet/puppetdb.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('puppetserver/puppetdb.conf.epp',
                   { 'puppetdb_addr'   => $puppetdb_addr, }
                  ),
  }

  file { "$etc_path/puppet/routes.yaml":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/puppetserver/routes.yaml',
  }

  file { "$etc_path/puppet/puppet.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => epp('puppetserver/puppet.conf.epp',
                   {'ca_server'               => $ca_server,
                    'ca_myself'               => $ca_myself,
                    'puppet_server_for_agent' => $puppet_server_for_agent,
                    'puppetserver_for_myself' => $puppetserver_for_myself,
                    'module_repository'       => $module_repository,
                   }
                  ),
  }

  # Installation de eyaml etc.
  file { "${etc_path}/puppet/keys":
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0755',
    before => [
                Exec['install-gem-hiera-eyaml'],
                Exec['install-gem-deep-merge'],
                Exec['install-gem-hiera-eyaml-for-user'],
                Exec['install-gem-deep-merge-for-user'],
              ],
  }

  exec { 'install-gem-hiera-eyaml':
    command => '/opt/puppetlabs/bin/puppetserver gem install hiera-eyaml --no-ri --no-rdoc',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => 'test -e /opt/puppetlabs/server/data/puppetserver/jruby-gems/bin/eyaml',
  }

  exec { 'install-gem-deep-merge':
    command => '/opt/puppetlabs/bin/puppetserver gem install deep_merge --no-ri --no-rdoc',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => "find /opt/puppetlabs/server/data/puppetserver -type f -name 'deep_merge.rb' | grep -Eq '.'",
  }

  # Above the installation for puppetserver with Jruby.
  # But we must install the gems for users too. I think
  # it's the same program and only the interpretor changes.
  # TODO: I thought that a user could take the gem from the
  # puppetserver mais I have not found the way.
  exec { 'install-gem-hiera-eyaml-for-user':
    command => '/opt/puppetlabs/puppet/bin/gem install hiera-eyaml',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => '/opt/puppetlabs/puppet/bin/gem list | grep -q "^hiera-eyaml "',
  }

  exec { 'install-gem-deep-merge-for-user':
    command => '/opt/puppetlabs/puppet/bin/gem install deep_merge',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => '/opt/puppetlabs/puppet/bin/gem list | grep -q "^deep_merge "',
  }

  file { $eyaml_public_key:
    ensure  => present,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0400',
    content => file($eyaml_public_key),
  }

  file { $eyaml_private_key:
    ensure  => present,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0400',
    content => file($eyaml_private_key),
  }

}



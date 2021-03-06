class puppetmaster::puppet_config {

  private("Sorry, ${title} is a private class.")

  # Some common variables of this class.
  $module_repository     = $::puppetmaster::module_repository
  $environment_path      = $::puppetmaster::environment_path
  $ca_server             = $::puppetmaster::ca_server
  $generate_eyaml_keys   = $::puppetmaster::generate_eyaml_keys
  $extdata               = $::puppetmaster::extdata
  $enc_path              = '/usr/local/bin/enc'
  $yaml_conf             = '/etc/hiera.yaml'
  $eyaml_public_key      = '/etc/puppet/keys/public_key.pkcs7.pem'
  $eyaml_private_key     = '/etc/puppet/keys/private_key.pkcs7.pem'
  $eyaml_create_keys_cmd = "eyaml createkeys --pkcs7-private-key \
${eyaml_private_key} --pkcs7-public-key ${eyaml_public_key}"

  # The environment directories and its sub-directories etc.
  file { [
          $environment_path,
          "${environment_path}/production",
          "${environment_path}/production/hieradata",
          "${environment_path}/production/modules",
          "${environment_path}/production/manifests",
          "/etc/puppet/extdata",
         ]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    before => Service['apache2'],
    notify => Service['apache2'],
  }

  file { '/etc/puppet/extdata/common.csv':
    ensure  => present,
    owner   => 'puppet',
    group   => 'puppet',
    mode    => '0400',
    content => inline_template("<%- @extdata.each do |key,value| -%>
<%= key %>,<%= value %>
<%- end -%>

"),
    before  => Service['apache2'],
    notify  => Service['apache2'],
  }

  # The site.pp file.
  file { "${environment_path}/production/manifests/site.pp":
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/puppetmaster/site.pp',
    before => Service['apache2'],
    notify => Service['apache2'],
  }

  # The ENC.
  file { 'enc-script':
    path    => $enc_path,
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('puppetmaster/enc.erb'),
    before  => Service['apache2'],
    notify  => Service['apache2'],
  }

  file { $yaml_conf:
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('puppetmaster/hiera.yaml.erb'),
    before  => Service['apache2'],
    notify  => Service['apache2'],
  }

  # Installation of "hiera-eyaml" and creation of the eyaml keys.
  file { '/etc/puppet/keys':
    ensure => directory,
    owner  => 'puppet',
    group  => 'puppet',
    mode   => '0755',
    before => [
               Exec['install-gem-hiera-eyaml'],
               Exec['install-gem-deep-merge'],
               Service['apache2'],
              ],
    notify => Service['apache2'],
  }

  exec { 'install-gem-hiera-eyaml':
    command => 'gem install hiera-eyaml',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => 'gem list | grep -q "^hiera-eyaml "',
    before  => Service['apache2'],
    notify  => Service['apache2'],
  }

  exec { 'install-gem-deep-merge':
    command => 'gem install deep_merge',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => 'gem list | grep -q "^deep_merge "',
    before  => Service['apache2'],
    notify  => Service['apache2'],
  }

  if $generate_eyaml_keys {

    # Automatic generation of the eyaml keys.

    exec { 'generate-eyaml-keys':
      command => $eyaml_create_keys_cmd,
      path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      user    => 'root',
      group   => 'root',
      unless  => 'test -e /etc/puppet/keys/private_key.pkcs7.pem',
      require => [
                   Exec['install-gem-hiera-eyaml'],
                   Exec['install-gem-deep-merge'],
                 ],
      before  => [
                  File[$eyaml_public_key],
                  File[$eyaml_private_key],
                  Service['apache2'],
                 ],
      notify  => Service['apache2'],
    }

    file { $eyaml_public_key:
      ensure => present,
      owner  => 'puppet',
      group  => 'puppet',
      mode   => '0400',
      before => Service['apache2'],
      notify => Service['apache2'],
    }

    file { $eyaml_private_key:
      ensure => present,
      owner  => 'puppet',
      group  => 'puppet',
      mode   => '0400',
      before => Service['apache2'],
      notify => Service['apache2'],
    }

  } else {

    # We use the same eyaml keys of the puppetmaster
    # which manages the current new puppetmaster.

    file { $eyaml_public_key:
      ensure  => present,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0400',
      before  => Service['apache2'],
      notify  => Service['apache2'],
      content => file($eyaml_public_key),
    }

    file { $eyaml_private_key:
      ensure  => present,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0400',
      before  => Service['apache2'],
      notify  => Service['apache2'],
      content => file($eyaml_private_key),
    }

  }

  # The puppetdb.conf. This file explain to Puppet how to
  # contact the puppetdb. You must use a https connection,
  # so the localhost address is impossible.
  file { '/etc/puppet/puppetdb.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppetmaster/puppetdb.conf.erb'),
    before  => Service['apache2'],
    notify  => Service['apache2'],
  }

  file { '/etc/puppet/routes.yaml':
    ensure => present,
    owner  => 'root',
    group  => 'root',
    mode   => '0644',
    source => 'puppet:///modules/puppetmaster/routes.yaml',
    before => Service['apache2'],
    notify => Service['apache2'],
  }

  file { '/etc/puppet/puppet.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('puppetmaster/puppet.conf.erb'),
    before  => Service['apache2'],
    notify  => Service['apache2'],
  }

  file_line { 'set-locale-apache':
    path    => '/etc/apache2/envvars',
    line    => ". /etc/default/locale # Edited by Puppet.",
    match   => '^[[:space:]]*#?[[:space:]]*\.[[:space:]]*/etc/default/locale.*$',
    before  => Service['apache2'],
    notify  => Service['apache2'],
  }

  exec { "disable-site-default":
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    command => "a2dissite 000-default.conf",
    onlyif  => "test -L /etc/apache2/sites-enabled/000-default.conf",
    notify  => Service['apache2'],
    before  => Service['apache2'],
  }

  # It's better to have the "Listen" instruction in the
  # "ports.conf" file. "Listen" will be removed from the
  # vhost file below.
  file { '/etc/apache2/ports.conf':
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => "# This file is managed by Puppet, don't edit it.

Listen 0.0.0.0:8140

",
    before  => Service['apache2'],
    notify  => Service['apache2'],
  }

  file_line { 'vhost-remove-listen':
    path    => '/etc/apache2/sites-available/puppetmaster.conf',
    line    => "#Listen 8140 # Lines of this file edited by Puppet.",
    match   => '^[[:space:]]*#?[[:space:]]*Listen .*$',
    before  => Service['apache2'],
    notify  => Service['apache2'],
  }

  if $ca_server != '<myself>' {

    # The puppetmaster isn't the CA.

    # In this case, apache2 must use the certificates in the
    # /var/lib/puppet/sslclient directory.

    file_line { 'vhost-SSLCertificateFile':
      path    => '/etc/apache2/sites-available/puppetmaster.conf',
      line    => "  SSLCertificateFile /var/lib/puppet/sslclient/certs/${::fqdn}.pem",
      match   => '^[[:space:]]*SSLCertificateFile[[:space:]]+.*$',
      before  => Service['apache2'],
      notify  => Service['apache2'],
    }

    file_line { 'vhost-SSLCertificateKeyFile':
      path    => '/etc/apache2/sites-available/puppetmaster.conf',
      line    => "  SSLCertificateKeyFile /var/lib/puppet/sslclient/private_keys/${::fqdn}.pem",
      match   => '^[[:space:]]*SSLCertificateKeyFile[[:space:]]+.*$',
      before  => Service['apache2'],
      notify  => Service['apache2'],
    }

    file_line { 'vhost-SSLCertificateChainFile':
      path    => '/etc/apache2/sites-available/puppetmaster.conf',
      line    => "  SSLCertificateChainFile /var/lib/puppet/sslclient/certs/ca.pem",
      match   => '^[[:space:]]*SSLCertificateChainFile[[:space:]]+.*$',
      before  => Service['apache2'],
      notify  => Service['apache2'],
    }

    file_line { 'vhost-SSLCACertificateFile':
      path    => '/etc/apache2/sites-available/puppetmaster.conf',
      line    => "  SSLCACertificateFile /var/lib/puppet/sslclient/certs/ca.pem",
      match   => '^[[:space:]]*SSLCACertificateFile[[:space:]]+.*$',
      before  => Service['apache2'],
      notify  => Service['apache2'],
    }

    file_line { 'vhost-SSLCARevocationFile':
      path    => '/etc/apache2/sites-available/puppetmaster.conf',
      line    => "  SSLCARevocationFile /var/lib/puppet/sslclient/crl.pem",
      match   => '^[[:space:]]*SSLCARevocationFile[[:space:]]+.*$',
      before  => Service['apache2'],
      notify  => Service['apache2'],
    }

    exec { 'remove-useless-ssldir':
      command => 'rm -rf /var/lib/puppet/ssl',
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      user    => 'root',
      group   => 'root',
      onlyif  => 'test -d /var/lib/puppet/ssl',
      before  => Service['apache2'],
    }

    # Very important ! If the puppetmaster isn't the CA, it must
    # update its local copy of the CRL of the CA puppetmaster.
    file { '/var/lib/puppet/sslclient/crl.pem':
      ensure  => present,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0644',
      content => file('/var/lib/puppet/ssl/ca/ca_crl.pem'),
      before  => Service['apache2'],
      # I thought that restart apache2 was useless, but according
      # to my tests, in fact it's completely necessary. If apache2
      # is not restarted, it uses the old version of this file
      # (ie a old version of the CRL). In fact, a simple "reload"
      # just works.
      notify  => Service['apache2'],
    }

  } else {

    # The puppetmaster is the CA.

    # In this case, when the CRL is udpated, apache2 must be
    # restarted (or just reloaded). How to check if the CRL
    # has been changed? Very simple:
    #
    #   - /var/lib/puppet/ssl/ca/ca_crl.pem is the updated CRL of the CA
    #   - /var/lib/puppet/ssl/crl.pem is the not necessary updated CRL
    #     of the puppet agent of the puppetmaster
    #
    # These 2 files should be equal. If not, the ca_crl.pem file
    # has been change. In this case, we will update the
    # /var/lib/puppet/ssl/crl.pem file and trigger a restart
    # of apache2.

    # We don't care about this file. It's just a way to restart
    # apache2 if the CRL of the CA has been updated.
    file { '/var/lib/puppet/ssl/crl.pem':
      ensure  => present,
      owner   => 'puppet',
      group   => 'puppet',
      mode    => '0644',
      content => file('/var/lib/puppet/ssl/ca/ca_crl.pem'),
      before  => Service['apache2'],
      notify  => Service['apache2'],
    }

  }

  # TODO: this resource will be useful for a resfresh
  # of apache2 when CRL is updated (which can happen
  # often). But unfortunately, in some cases there will
  # a consecutive reload and a restart of apache2. This is
  # not very nice. I don't know (it seems impossible) how to
  # cancel the reload of apache2 ("exec" resource) if the
  # restart ("service" resource) is scheduled by Puppet.
  #
  # There will be a reload of apache only when CRL will
  # updated because this event can happen often.
  #exec { "reload-apache2":
  #  path        => '/usr/sbin:/usr/bin:/sbin:/bin',
  #  user        => 'root',
  #  group       => 'root',
  #  command     => "service apache2 reload",
  #  refreshonly => true,
  #  before      => Service['apache2'],
  #}

  service { 'apache2':
    ensure     => running,
    hasstatus  => true,
    # "restart" command exists but sometimes it fails with:
    #
    #   make_sock: could not bind to address...
    #
    # A "stop", a "sleep" and a "start" seem to be more safer.
    hasrestart => false,
    restart    => 'service apache2 stop; sleep 2; service apache2 start',
  }

}



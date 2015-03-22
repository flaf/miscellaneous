class puppetmaster::puppet_config {

  private("Sorry, ${title} is a private class.")

  # Some common variables of this class.
  $module_repository     = $::puppetmaster::module_repository
  $enc_path              = '/usr/local/bin/enc'
  $environment_path      = '/puppet'
  $yaml_conf             = '/etc/hiera.yaml'
  $eyaml_public_key      = '/etc/puppet/keys/public_key.pkcs7.pem'
  $eyaml_private_key     = '/etc/puppet/keys/private_key.pkcs7.pem'
  $eyaml_create_keys_cmd = "eyaml createkeys --pkcs7-private-key \
${eyaml_private_key} --pkcs7-public-key ${eyaml_public_key}"

  # The environment director and its sub-directories.
  file { [
          $environment_path,
          "${environment_path}/production",
          "${environment_path}/production/hieradata",
          "${environment_path}/production/modules",
          "${environment_path}/production/manifests",
         ]:
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    before => Service['apache2'],
    notify => Service['apache2'],
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
               Exec['install-hiera-eyaml'],
               Service['apache2'],
              ],
    notify => Service['apache2'],
  }

  exec { 'install-hiera-eyaml':
    command => 'gem install hiera-eyaml',
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => 'gem list | grep -q "^hiera-eyaml "',
    before  => [
                Exec['generate-eyaml-keys'],
                Service['apache2'],
               ],
    notify  => Service['apache2'],
  }

  exec { 'generate-eyaml-keys':
    command => $eyaml_create_keys_cmd,
    path    => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    unless  => 'test -e /etc/puppet/keys/private_key.pkcs7.pem',
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

  # The puppetdb.conf. Explain to Puppet how to contact
  # the puppetdb. You must use a https connection, so
  # the localhost address is impossible.
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

  service { 'apache2':
    ensure     => running,
    hasstatus  => true,
    hasrestart => true,
  }

}



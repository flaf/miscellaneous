#
# Private class.
#
define ceph::radosgw (
  $cluster_name = 'ceph',
  $account,
  $admin_mail,
){

  private("Sorry, ${title} is a private class.")

  case $::lsbdistcodename {
    trusty: {}
    default: {
      fail("Class ${title} has never been tested on ${::lsbdistcodename}.")
    }
  }

  require '::ceph::radosgw::packages'

  $options     = "-c /etc/ceph/${cluster_name}.conf -n client.${account}"
  $script_fcgi = "#!/bin/sh\nexec /usr/bin/radosgw ${options}\n"
  $bin         = "s3gw-${cluster_name}.fcgi"
  $cmd_fcgi    = "/var/www/$bin"

  file { "${cmd_fcgi}":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => $script_fcgi,
    notify  => Service['apache2'],
    before  => Service['apache2'],
  }

  file { "/var/lib/ceph/radosgw/${cluster_name}-${account}":
    ensure  => directory,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    recurse => false,
    purge   => false,
    force   => false,
    before  => Service['apache2'],
  }

  file { "/var/lib/ceph/radosgw/${cluster_name}-${account}/done":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => "# Managed by Puppet.\n",
    before  => Service['apache2'],
  }

  file { "/etc/apache2/sites-available/${cluster_name}.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
    content => template('ceph/radosgw-vhost.conf.erb'),
    notify  => Service['apache2'],
    before  => Service['apache2'],
  }

  exec { "enable-site-${cluster_name}":
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    command => "a2ensite ${cluster_name}.conf",
    unless  => "test -L /etc/apache2/sites-enabled/${cluster_name}.conf",
    notify  => Service['apache2'],
    before  => Service['apache2'],
  }

  # Avoid duplicated exec resource.
  if !defined(Exec['disable-site-default']) {
    exec { "disable-site-default":
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      user    => 'root',
      group   => 'root',
      command => "a2dissite 000-default.conf",
      onlyif  => "test -L /etc/apache2/sites-enabled/000-default.conf",
      notify  => Service['apache2'],
      before  => Service['apache2'],
    }
  }

  # To avoid duplicated management of this file.
  if !defined(File['/etc/apache2/conf-available/ceph.conf']) {
    file { '/etc/apache2/conf-available/ceph.conf':
      ensure  => present,
      owner   => 'root',
      group   => 'root',
      mode    => '0755',
      content => "# Managed by Puppet.\nServerName ${::fqdn}\n",
      notify  => Service['apache2'],
      before  => Service['apache2'],
    }
  }

  # Avoid duplicated exec resource.
  if !defined(Exec['enable-ceph-conf']) {
    exec { 'enable-ceph-conf':
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      user    => 'root',
      group   => 'root',
      command => 'a2enconf ceph.conf',
      unless  => 'test -L /etc/apache2/conf-enabled/ceph.conf',
      notify  => Service['apache2'],
      before  => Service['apache2'],
    }
  }

  # Avoid duplicated exec resource.
  if !defined(Exec['enable-rewrite-mod']) {
    exec { 'enable-rewrite-mod':
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      user    => 'root',
      group   => 'root',
      command => 'a2enmod rewrite',
      unless  => 'test -L /etc/apache2/mods-enabled/rewrite.load',
      notify  => Service['apache2'],
      before  => Service['apache2'],
    }
  }

  # Avoid duplicated exec resource.
  if !defined(Exec['enable-fastcgi-mod']) {
    exec { 'enable-fastcgi-mod':
      path    => '/usr/sbin:/usr/bin:/sbin:/bin',
      user    => 'root',
      group   => 'root',
      command => 'a2enmod fastcgi',
      unless  => 'test -L /etc/apache2/mods-enabled/fastcgi.load',
      notify  => Service['apache2'],
      before  => Service['apache2'],
    }
  }

  # Avoid duplicated service resource.
  if !defined(Service['apache2']) {
    service { 'apache2':
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
    }
  }

  exec { "radosgw-${cluster_name}-${account}":
    path    => '/usr/sbin:/usr/bin:/sbin:/bin',
    user    => 'root',
    group   => 'root',
    command => "service radosgw restart cluster=${cluster_name} id=${account}",
    unless  => "service radosgw status cluster=${cluster_name} id=${account}",
    require => Service['apache2'],
  }

}



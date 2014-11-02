class shinken::server::config {

  require 'shinken::server::params'

  $managed_dir           = $shinken::server::params::managed_dir
  $lib_dir               = $shinken::server::params::lib_dir
  $run_dir               = $shinken::server::params::run_dir
  $log_dir               = $shinken::server::params::log_dir
  $conf_dir              = $shinken::server::params::conf_dir
  $shinken_packs_dir     = $shinken::server::params::shinken_packs_dir
  $exported_dir          = $shinken::server::params::exported_dir

  $nagios_file           = $shinken::server::params::nagios_file
  $shinken_specific_file = $shinken::server::params::shinken_specific_file
  $manual_hosts_file     = $shinken::server::params::manual_hosts_file
  $puppet_hosts_file     = $shinken::server::params::puppet_hosts_file
  $htpasswd_file         = $shinken::server::params::htpasswd_file
  $resources_file        = $shinken::server::params::resources_file
  $basis_file            = $shinken::server::params::basis_file
  $contacts_file         = $shinken::server::params::contacts_file
  $irc_pipe_file         = $shinken::server::params::irc_pipe_file
  $black_list_file       = $shinken::server::params::black_list_file
  $exported2conf_file    = $shinken::server::params::exported2conf_file

  $nagios_plugins_dir    = $shinken::server::params::nagios_plugins_dir
  $sp_plugins_dir        = $shinken::server::params::sp_plugins_dir

  # The LDAP configuration if it exists.
  # Used in the shinken configuration only if $ldap_account is defined
  # i.e. only if there is a 'monitoring_account' key.
  $ldap_account          = $shinken::server::params::ldap_account
  $ldap_password         = $shinken::server::params::ldap_password
  $ldap_basedn           = $shinken::server::params::ldap_basedn
  $ldap_uri              = $shinken::server::params::ldap_uri

  $ipmi_account          = $shinken::server::params::ipmi_account
  $ipmi_password         = $shinken::server::params::ipmi_password

  $secname               = $shinken::server::params::secname
  $authpass              = $shinken::server::params::authpass
  $authproto             = $shinken::server::params::authproto
  $privpass              = $shinken::server::params::privpass
  $privproto             = $shinken::server::params::privproto
  $pfsense_community     = $shinken::server::params::pfsense_community

  $ftp_account           = $shinken::server::params::ftp_account
  $ftp_password          = $shinken::server::params::ftp_password

  $windows_account       = $shinken::server::params::windows_account
  $windows_password      = $shinken::server::params::windows_password

  $contacts              = $shinken::server::params::contacts
  $url_for_sms           = $shinken::server::params::url_for_sms
  $sms_threshold         = $shinken::server::params::sms_threshold
  $rarefaction_threshold = $shinken::server::params::rarefaction_threshold
  $additional_macros     = $shinken::server::params::additional_macros
  $manual_hosts          = $shinken::server::params::manual_hosts
  $black_list            = $shinken::server::params::black_list
  $key4cookies           = $shinken::server::params::key4cookies
  $tag                   = $shinken::server::params::tag

  # Frequently, it's just necessary to restart the
  # shinken-arbiter daemon.
  service { 'shinken-arbiter':
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
  }

  # And sometimes we must restart all the shinken daemons.
  service { 'shinken':
      ensure     => running,
      hasstatus  => true,
      hasrestart => true,
  }

  # Default values for the "file" resources.
  File {
    ensure => present,
    owner  => 'shinken',
    group  => 'shinken',
    mode   => 640,
    # Allowing exception, all files must notify the shinken-arbiter.
    notify => Service['shinken-arbiter'],
    # The execution of exported2conf must be at
    # the end, when all files are created.
    # Chaining with exported resources is DANGEROUS!
    before => Exec['update_puppet_hosts'],
  }

  file { $managed_dir:
    ensure  => directory,
    mode    => 750,
    recurse => true,
    purge   => true,
    force   => true,
  }

  file { $nagios_file:
    content => template('shinken/server/nagios.cfg.erb'),
  }

  file { $shinken_specific_file:
    content => template('shinken/server/shinken-specific.cfg.erb'),
    # A change in this files implies to restart all the services,
    # not just the "shinken-arbiter" service.
    notify  => Service['shinken'],
  }

  file { $htpasswd_file:
    mode    => 600,
    content => template('shinken/server/htpasswd.erb'),
    # It's just a data file, not a configuration file.
    notify  => undef,
  }

  file { $resources_file:
    mode    => 600,
    content => template('shinken/server/resources.cfg.erb'),
  }

  file { $basis_file:
    content => template('shinken/server/basis.cfg.erb'),
  }

  file { $contacts_file:
    content => template('shinken/server/contacts.cfg.erb'),
  }

  file { $manual_hosts_file:
    content => template('shinken/server/manual_hosts.cfg.erb'),
  }

  file { $black_list_file:
    content => template("shinken/server/black_list.erb"),
    notify  => undef,
  }

  file { $puppet_hosts_file:
    # Content managed by the exec resource below.
    # No content describe here.
  }

  file { $exported2conf_file:
    mode    => 750,
    content => template('shinken/server/exported2conf.erb'),
    notify  => undef,
  }

  # Files exported by the nodes.
  File <<| tag == $tag |>> {
    # I don't know why but, in some cases, I have seen
    # exported files which don't retrieved the default
    # properties given in the "File {....}" instruction
    # above.  Obviously, it doesn't happen when I repeat
    # here the default properties.
    ensure => present,
    owner  => 'shinken',
    group  => 'shinken',
    mode   => 640,
    notify => undef,
    before => Exec['update_puppet_hosts'],
  }

  exec { 'update_puppet_hosts':
    command => "'$exported2conf_file'",
    path    => '/bin:/usr/bin',
    user    => 'shinken',
    group   => 'shinken',
    onlyif  => "test -x '$exported2conf_file' && '$exported2conf_file' has_changed",
    notify  => Service['shinken-arbiter'],
  }

}



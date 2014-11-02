class shinken::server::params {

  require 'shinken::common::params'

  # Warning: no space in the full path of
  # exported files. The script exported2conf
  # doesn't work in this case.

  $lib_dir               = $shinken::common::params::lib_dir
  $exported_dir          = $shinken::common::params::exported_dir
  $tag                   = $shinken::common::params::tag

  # Files and directories.
  $etc_dir               = '/etc/shinken'
  $log_dir               = '/var/log/shinken'
  $run_dir               = '/var/run/shinken'
  $shinken_packs_dir     = '/usr/share/shinken-packs/templates'
  $nagios_file           = "$etc_dir/nagios.cfg"
  $shinken_specific_file = "$etc_dir/shinken-specific.cfg"
  $conf_dir              = "$etc_dir/shinken.d"
  $puppet_hosts_file     = "$conf_dir/puppet_hosts.cfg"
  $manual_hosts_file     = "$conf_dir/manual_hosts.cfg"
  $resources_file        = "$conf_dir/resources.cfg"
  $basis_file            = "$conf_dir/basis.cfg"
  $contacts_file         = "$conf_dir/contacts.cfg"
  $black_list_file       = "$conf_dir/black_list"
  $htpasswd_file         = "$lib_dir/htpasswd"
  $exported2conf_file    = "$lib_dir/exported2conf"
  $irc_pipe_file         = "$lib_dir/irc_pipe"
  $botirc_conf_file      = '/etc/default/botirc-parrot'

  # Plugins directories.
  $nagios_plugins_dir  = '/usr/lib/nagios/plugins'
  $sp_plugins_dir      = '/usr/share/shinken-packs/libexec'

  # In these directories, no file wich aren't managed by Puppet.
  $managed_dir = [
    "$conf_dir",
    "$exported_dir",
  ]

  # The LDAP configuration if it exists.
  # Used in the shinken configuration only if $ldap_account is defined
  # i.e. only if there is a 'monitoring_account' key.
  $ldap_conf             = hiera_hash('ldap', undef)
  if ($ldap_conf != undef) {
    $ldap_account        = $ldap_conf['monitoring_account']
    if ($ldap_account != undef) {
      $ldap_basedn       = $ldap_conf['basedn']
      $ldap_uri          = $ldap_conf['uri']
      $ldap_password     = generate_password($ldap_conf['monitoring_password'])
    }
  }

  # IPMI configuration. Not mandatory.
  $ipmi_conf             = hiera_hash('ipmi', undef)
  if ($ipmi_conf != undef) {
    $ipmi_account        = $ipmi_conf['monitoring_account']
    $ipmi_password       = generate_password($ipmi_conf['monitoring_password'])
  }
  else {
    $ipmi_account        = ''
    $ipmi_password       = ''
  }

  # The SNMP configuration.
  $snmp_conf             = hiera_hash('snmp')
  $secname               = generate_password($snmp_conf['secname'])
  $authpass              = generate_password($snmp_conf['authpass'])
  $authproto             = $snmp_conf['authproto']
  $privpass              = generate_password($snmp_conf['privpass'])
  $privproto             = $snmp_conf['privproto']
  $pfsense_community     = generate_password($snmp_conf['pfsense_community'])

  # The FTP configuration. Not mandatory.
  $ftp_conf              = hiera_hash('ftp', undef)
  if ($ftp_conf != undef) {
    $ftp_account         = $ftp_conf['monitoring_account']
    $ftp_password        = generate_password($ftp_conf['monitoring_password'])
  }
  else {
    $ftp_account         = ''
    $ftp_password        = ''
  }

  # The Windows configuration. Not mandadory.
  $windows_conf          = hiera_hash('windows', undef)
  if ($windows_conf != undef) {
    $windows_account     = $windows_conf['monitoring_account']
    $windows_password    = generate_password($windows_conf['monitoring_password'])
  }
  else {
    $windows_account     = ''
    $windows_password    = ''
  }

  # The shinken configuration.
  $misc                  = hiera_hash('shinken_misc')
  $contacts              = hiera_hash('shinken_contacts', {})
  $black_list            = hiera_array('shinken_black_list', [])
  $additional_macros     = hiera_hash('shinken_additional_macros', {})
  $url_for_sms           = $misc['url_for_sms']
  $sms_threshold         = $misc['sms_threshold']
  $rarefaction_threshold = $misc['rarefaction_threshold']
  $manual_hosts          = $misc['manual_hosts']
  $irc_server            = $misc['irc_server']
  $irc_port              = $misc['irc_port']
  $irc_channel           = $misc['irc_channel']
  $irc_password          = generate_password($misc['irc_password'])
  $key4cookies           = generate_password('__pwd__{"nice" => true}')

  # Reverse proxy or not.
  if ($misc['reverse_proxy'] == 'true') {
    $reverse_proxy       = true
    $html_filter_bin     = '/usr/local/bin/html_filter'
    if ($misc['add_in_links'] == undef) {
      $add_in_links      = 'shinken'
    }
    else {
      $add_in_links      = $misc['add_in_links']
    }

  }
  else {
    $reverse_proxy       = false
  }

}



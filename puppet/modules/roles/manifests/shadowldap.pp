class roles::shadowldap {

  # TODO: create a basic module slapd, with an option to enable
  #       ssl or not and with.
  # TODO: in the module, manage a cron job to slapcat every day.
  #       Add an option to set retention etc.
  # TODO: management of a shinken check on _masterldap1_?

  include '::roles::generic'
  include '::keepalived_vip'

  $packages = [ 'slapd', 'ldap-utils', 'git', 'openssl', 'ca-certificates' ]
  ensure_packages( $packages, { ensure => present } )

  file_line { 'edit-etc-default-slapd':
    path    => '/etc/default/slapd',
    line    => 'SLAPD_SERVICES="ldap:/// ldaps:/// ldapi:///"',
    match   => '^[[:space:]]*SLAPD_SERVICES=.*$',
    require => Package['slapd'],
    notify  => Service['slapd'],
  }

  service { 'slapd':
    ensure     => running,
    hasrestart => true,
  }

  # Checkpoint to check is the process slapd is UP.

  $shadowldap_checkpoint_title = $::facts['networking']['fqdn'].with |$fqdn| { 
    "${fqdn} from ${title}"
  }

  monitoring::host::checkpoint {$shadowldap_checkpoint_title:
    templates        => ['linux_tpl'],
    custom_variables => [
      {
        'varname' => '_present_processes',
        'value'   => {'process-slapd' => ['slapd']},
        'comment' => ['The process "slapd" must be up.'],
      },
    ],
  }

}



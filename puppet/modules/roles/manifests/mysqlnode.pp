class roles::mysqlnode {

  # This present role include the role "generic".
  include '::roles::generic'

  include '::wrapper_mysql'

  # (i) No longer the case. Now, the VIP is checked via SNMP directly.
  #
  # We want to be able to monitor if the VIP(s) is (are) present.
  #$default_cron_check_cmd = ::keepalived_vip::data()['keepalived_vip::params::cron_check_cmd']
  #$cron_check_cmd         = ::roles::wrap_cron_mon('check-vip', $default_cron_check_cmd)

  class { '::keepalived_vip::params':
    # (i) No longer the case. Now, the VIP is checked via SNMP directly.
    #cron_check_vip => ::roles::is_number_one(),
    #cron_check_cmd => $cron_check_cmd,
    before         => Class['::keepalived_vip'],
  }

  include '::keepalived_vip'

}



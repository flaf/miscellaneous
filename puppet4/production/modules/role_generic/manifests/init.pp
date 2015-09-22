class role_generic {

  include '::unix_accounts'
  include '::network'
  include '::network::hosts'
  include '::network::resolv_conf'
  include '::network::ntp'
  include '::repository::distrib'
  include '::basic_ssh::server'
  include '::basic_ssh::client'
  include '::keyboard'
  include '::locale'
  include '::timezone'
  include '::puppetagent'
  include '::mcollective::server'

}



class role_generic {

  include '::network'
  include '::network::resolv_conf'
  include '::repository::distrib'
  include '::basic_ssh::server'
  include '::basic_ssh::client'
  include '::keyboard'
  include '::locale'
  include '::timezone'
  include '::ntp'
  include '::puppetagent'
  include '::mcollective::server'

}



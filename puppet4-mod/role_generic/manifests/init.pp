class role_generic {

  include '::network'
  include '::distrib_repositories'
  include '::basic_ssh::server'
  include '::basic_ssh::client'
  include '::keyboard'
  include '::locale'
  include '::timezone'
  include '::ntp'
  include '::puppetagent'

}



class role_generic {

  include '::basic_ssh::server'
  include '::basic_ssh::client'
  include '::keyboard'
  include '::locale'
  include '::timezone'
  include '::network'

}



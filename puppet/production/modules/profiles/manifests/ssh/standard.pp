class profiles::ssh::standard {

  include '::ssh::client'

  # Default conf, ie "PermitRootLogin yes".
  include '::ssh::server'

}



class profiles::ssh::generic {

  include '::ssh::client'

  # Default conf, ie "PermitRootLogin yes".
  include '::ssh::server'

}



class role_puppetserver {

  # This role inherits from the "role_generic" role.
  include '::role_generic'

  include '::puppetserver'

}



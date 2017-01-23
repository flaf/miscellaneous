class roles::mcomiddleforge {

  # The order here is important because the class
  # mcomiddleware::params is declared as resource-like
  # declaration in roles::mcomiddleware.
  include '::roles::mcomiddleware'
  include '::roles::puppetforge'

}



class roles::mcomiddleforge {

  # The order here is important.
  include '::roles::mcomiddleware'
  include '::roles::puppetforge'

}



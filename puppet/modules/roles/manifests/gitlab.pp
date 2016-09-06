class roles::gitlab {

  class { '::roles::generic::params':
    # We want to remove "::eximnullclient" from the excluded classes.
    excluded_classes => ::roles::data()['roles::generic::params::excluded_classes'] - [ '::eximnullclient' ]
  }

  include '::roles::generic'

}



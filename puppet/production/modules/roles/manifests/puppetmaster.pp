class roles::puppetmaster {

  # inheritance from "generic_without_puppet" roles.
  include '::roles::generic_without_puppet'

  include '::profiles::apt::puppetlabs'
  include '::profiles::puppet::puppetmaster'

}



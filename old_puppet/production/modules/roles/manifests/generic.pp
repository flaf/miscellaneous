class roles::generic {

  # inheritance from "generic_without_puppet" roles.
  include '::roles::generic_without_puppet'

  include '::profiles::puppet::generic'

}



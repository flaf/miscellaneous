class roles::generic_without_hosts {

  include '::profiles::network::generic'
  include '::profiles::timezone::generic'
  include '::profiles::locales::generic'
  include '::profiles::keyboard::generic'
  include '::profiles::apt::generic'
  include '::profiles::ntp::generic'
  include '::profiles::grub::generic'
  include '::profiles::puppet::generic'
  include '::profiles::ssh::generic'
  include '::profiles::misc::generic'

}





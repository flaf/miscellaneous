class roles::standard_without_hosts {

  include '::profiles::network::standard'
  include '::profiles::timezone::standard'
  include '::profiles::locales::standard'
  include '::profiles::keyboard::standard'
  include '::profiles::apt::standard'
  include '::profiles::ntp::standard'
  include '::profiles::grub::standard'
  include '::profiles::puppet::standard'
  include '::profiles::ssh::standard'
  include '::profiles::misc::standard'

}




class roles::standard {

  include '::profiles::network::standard'
  include '::profiles::timezone::standard'
  include '::profiles::locales::standard'
  include '::profiles::keyboard::standard'
  include '::profiles::sourceslist::standard'
  include '::profiles::ntp::standard'
  include '::profiles::grub::standard'

}


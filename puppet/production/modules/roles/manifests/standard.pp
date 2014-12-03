class roles::sandbox {

  include '::profiles::network::standard'
  include '::profiles::timezone::standard'
  include '::profiles::locales::standard'
  include '::profiles::keyboard::standard'

}


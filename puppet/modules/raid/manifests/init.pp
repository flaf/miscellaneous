class raid {

  include '::raid::params'
  $raid_controllers = $::raid::params::raid_controllers
  $controller2class = $::raid::params::controller2class

  $raid_controllers.each |$raid_controller| {
    if $controller2class.has_key($raid_controller) {
      $a_class = $controller2class[$raid_controller]
      include "::raid::${a_class}"
    }
  }

}



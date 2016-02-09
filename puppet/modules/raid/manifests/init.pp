class raid {

  $params_class     = '::raid::params'
  if !defined(Class[$params_class]) { include $params_class }
  $raid_controllers = $::raid::params::raid_controllers
  $controller2class = $::raid::params::controller2class

  $raid_controllers.each |$raid_controller| {
    if $controller2class.has_key($raid_controller) {
      $a_class = $controller2class[$raid_controller]
      include "::raid::${a_class}"
    }
  }

}



class raid {

  include '::raid::params'

  $raid_controllers    = $::raid::params::raid_controllers
  $classes2controllers = $::raid::params::classes2controllers

  $raid_controllers.each |$raid_controller| {
    $classes2controllers.each |String[1] $this_class, Array[String[1], 1] $controllers_for_this_class | {
      if $controllers_for_this_class.member($raid_controller) {
        include "::raid::${this_class}"
      }
    }
  }

}



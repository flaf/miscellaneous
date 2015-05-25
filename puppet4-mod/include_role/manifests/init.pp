# The "role" attribute must be a non empty string.
class include_role (
  String[1] $role
) {

  include $role

}



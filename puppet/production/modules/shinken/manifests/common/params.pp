class shinken::common::params {

  $tag_temp     = hiera('shinken_tag', undef)
  $lib_dir      = '/var/lib/shinken'
  $exported_dir = "$lib_dir/exported"

  # Set the tag to default value if not defined.
  # We use $datacenter variable if defined to
  # set the default value.
  if ($tag_temp == undef) {
    if ($datacenter == undef) {
      $tag      = 'shinken_tag'
    }
    else {
      $tag      = "shinken_$datacenter"
    }
  }
  else {
    $tag        = $tag_temp
  }

}



class shinken::node::params {

  require 'shinken::common::params'

  $exported_dir         = $shinken::common::params::exported_dir
  $tag                  = $shinken::common::params::tag

  $additional_templates = hiera_array('shinken_node_templates', undef)
  $properties           = hiera_hash('shinken_node_properties', undef)

}



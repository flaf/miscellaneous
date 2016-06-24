class roles::moobotnode {

  include '::roles::moobotnode::params'
  $nodetype = $::roles::moobotnode::params::nodetype

  include '::moo::common::params'
  $moobot_conf = $::moo::common::params::moobot_conf,

  case $nodetype {

    'cargo': {
      include '::roles::ceph'
    }

    default: {
    }

  }

  class { "::moo::${nodetype}":
    moobot_conf => $moobot_conf_completed,
  }

}



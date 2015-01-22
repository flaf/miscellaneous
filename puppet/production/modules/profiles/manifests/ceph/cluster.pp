class profiles::ceph::cluster {

  require '::profiles::ceph::params'

  $cluster = $::profiles::ceph::params::cluster

  create_resources('::ceph::cluster', $cluster)

}



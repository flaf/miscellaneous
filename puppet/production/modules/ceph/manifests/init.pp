#
# For the "osd pool default pg num" parameter:
# http://ceph.com/docs/master/rados/operations/placement-groups/#a-preselection-of-pg-num
#
# For the "osd pool default pgp num" parameter:
# http://ceph.com/docs/master/rados/operations/placement-groups/#set-the-number-of-placement-groups
#
class ceph (
  $cluster_name          = 'ceph',
  $osd_journal_size      = 1024,
  $osd_pool_default_size = 2,
  $fsid,
) {

  validate_string($cluster_name)

  require '::ceph::packages'


  file { "/etc/ceph/${cluster_name}.conf":
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('ceph/ceph.conf.erb'),
  }

}



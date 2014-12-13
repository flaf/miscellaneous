#
# For the "osd pool default pg num" parameter:
# http://ceph.com/docs/master/rados/operations/placement-groups/#a-preselection-of-pg-num
#
# For the "osd pool default pgp num" parameter:
# http://ceph.com/docs/master/rados/operations/placement-groups/#set-the-number-of-placement-groups
#
class ceph (
  $cluster_name            = 'ceph',
  $osd_journal_size        = '1024',
  $osd_pool_default_size   = '2',
  $osd_pool_default_pg_num = '256',
  $monitors,
  $admin_key,
  $fsid,
) {

  validate_string(
    $cluster_name,
    $osd_journal_size,
    $osd_pool_default_size,
    $osd_pool_default_pg_num,
    $admin_key,
    $fsid,
  )
  validate_hash($monitors)

  $monitor_init = get_monitor_init_($monitors)

  require '::ceph::packages'
  require '::ceph::config'

  if has_key($monitors, $::hostname) {
    if has_key($monitors[$::hostname], 'initial') {
      include '::ceph::monitor_init'
    } else {
      include '::ceph::monitors'
    }
  }

  include '::ceph::osds'

}



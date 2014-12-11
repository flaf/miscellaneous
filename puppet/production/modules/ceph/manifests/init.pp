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
  $monitor_init,
  $monitors,
  $monitors_key,
  $admin_key,
  $fsid,
) {

  validate_string(
    $cluster_name,
    $osd_journal_size,
    $osd_pool_default_size,
    $osd_pool_default_pg_num,
    $monitor_init,
    $monitors_key,
    $admin_key,
    $fsid,
  )
  validate_hash($monitors)

  require '::ceph::packages'
  require '::ceph::config'

}



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

  # Internal variables.
  $monitor_init      = get_monitor_init_($monitors)
  $monitor_init_addr = $monitors[$monitor_init]['address']
  $id                = $monitors[$::hostname]['id']
  $monitor_init_cmd  = '/usr/local/sbin/ceph_monitor_init'
  $monitor_add_cmd   = '/usr/local/sbin/ceph_monitor_add'

  require '::ceph::packages'
  require '::ceph::config'

  if has_key($monitors, $::hostname) {

    if has_key($monitors[$::hostname], 'initial') {

      exec { "monitor-init-${cluster_name}":
        command => "$monitor_init_cmd --cluster $cluster_name --id $id",
        user    => 'root',
        group   => 'root',
        #onlyif  => "$monitor_init_cmd -c '$cluster_name' -i $id --test",
        onlyif  => "false",
      }

    } else {

      exec { "monitor-add-${cluster_name}":
        command => "$monitor_add_cmd -c $cluster_name -i $id -m $monitor_init_addr",
        user    => 'root',
        group   => 'root',
        #onlyif  => "$monitor_add_cmd --test -c ${luster_name -i $id -m $monitor_init_addr",
        onlyif  => "false",
      }

    }
  }

}



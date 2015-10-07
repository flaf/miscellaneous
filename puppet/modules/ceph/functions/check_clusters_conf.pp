function ceph::check_clusters_conf (
  Hash[String[1], Hash[String[1], Data, 1], 1] $clusters_conf
) {

  $clusters_conf.each |$cluster_name, $settings| {

    unless $settings.has_key('global_options')
    and $settings['global_options'] =~ Hash[String[1], String[1], 1] {
      @("END").regsubst('\n', ' ', 'G').fail
        ceph: the cluster `$cluster_name` must have the `global_options`
        key and its value must be a non-empty hash of non-empty strings.
        |- END
    }

    $monitors_value_type = Hash[ String[1], Hash[String[1], String[1], 2], 1 ]

    unless $settings.has_key('monitors')
    and $settings['monitors'] =~ $monitors_value_type {
      @("END").regsubst('\n', ' ', 'G').fail
        ceph: the cluster `$cluster_name` must have the `monitors`
        key and its value must have a specific type described in
        the documentation of the ceph module.
        |- END
    }

    $settings['monitors'].each |$monitor, $params| {
      [ 'id', 'address'].each |$a_param| {
        unless $params.has_key($a_param)
        and $params[$a_param] =~ String[1] {
          @("END").regsubst('\n', ' ', 'G').fail
            ceph: in the cluster `$cluster_name`, the monitor `$monitor`
            must have the key `$a_param` and its value must be a non-empty
            string.
            |- END
        }
      }
    }

    $keyrings_value_type = Hash[ String[1], Data, 1 ]

    unless $settings.has_key('keyrings')
    and $settings['keyrings'] =~ Hash[String[1], $keyrings_value_type, 1] {
      @("END").regsubst('\n', ' ', 'G').fail
        ceph: the cluster `$cluster_name` must have the `keyrings`
        key and its value must be a non-empty hash where the keys
        are non-empty strings and the values are non-empty hashes
        (see the documentation of the ceph module to have more details).
        |- END
    }

    $keyrings = $settings['keyrings']

    $keyrings.each |$account, $params| {

      unless $params.has_key('key') and $params['key'] =~ String[1] {
        @("END").regsubst('\n', ' ', 'G').fail
          ceph: in the keyring `$account` of the cluster `$cluster_name`,
          the key `key` must exist and its value must be a non-empty string.
          |- END
      }

      unless $params.has_key('properties')
      and $params['properties'] =~ Array[String[1], 1] {
        @("END").regsubst('\n', ' ', 'G').fail
          ceph: in the keyring `$account` of the cluster `$cluster_name`,
          the key `properties` must exist and its value must be a non-empty
          array of non-empty strings.
          |- END
      }

      [ 'owner', 'group', 'mode' ].each |$a_param| {
        if $params.has_key($a_param) {
          unless $params[$a_param] =~ String[1] {
            @("END").regsubst('\n', ' ', 'G').fail
              ceph: in the keyring `$account` of the cluster `$cluster_name`,
              the value of the optional key `$a_param` must be a non-empty
              string.
              |- END
          }
        }
      }

      # Specific case of radosgw.
      if $account =~ /^radosgw/ {

        # The key `radosgw_host` is mandatory.
        unless $params.has_key('radosgw_host')
        and $params['radosgw_host'] =~ String[1] {
          @("END").regsubst('\n', ' ', 'G').fail
            ceph: in the keyring `$account` of the cluster `$cluster_name`,
            the key `radosgw_host` must exist and its value must be a
            non-empty string.
            |- END
        }

        # The optional key `rgw_dns_name` must be a non-empty string.
        if $params.has_key('rgw_dns_name') {
          unless $params['rgw_dns_name'] =~ String[1] {
            @("END").regsubst('\n', ' ', 'G').fail
              ceph: in the keyring `$account` of the cluster `$cluster_name`,
              the value of the optional key `rgw_dns_name` must be a non-empty
              string.
              |- END
          }
        }

      } # Spefic case of radosgw keyring.

    } # Loop in $keyrings.

  } # Loop in clusters_conf

  # All is OK.
  true

}



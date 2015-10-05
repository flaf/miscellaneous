define ceph::common::keyring (
  String[1]           $cluster_name,
  String[1]           $account,
  String[1]           $key,
  Array[String[1], 1] $properties,
  String[1]           $owner         = 'root',
  String[1]           $group         = 'root',
  String[1]           $mode          = '0600',
) {

  $filename = "/etc/ceph/${cluster_name}.client.${account}.keyring"

  # Maybe the node is client and server too. In this case,
  # the resource defined by the class called at first wins.
  if !defined(File[$filename]) {

    file { $filename:
      ensure  => present,
      owner   => $owner,
      group   => $group,
      mode    => $mode,
      content => epp('ceph/ceph.client.keyring.epp',
                     {
                      'account'    => $account,
                      'key'        => $key,
                      'properties' => $properties,
                     }
                    ),
    }

  }

}



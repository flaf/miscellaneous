# User defined type to manage the keyring of a specific ceph
# account in a ceph server node.
#
# == Requirement/Dependencies
#
# Depends on Puppetlabs-stdlib and homemade_functions modules.
#
# == Parameters
#
# *cluster_name:*
# The name of the ceph cluster. The default value of this
# parameter is 'ceph'.
#
# *account:*
# String which gives the name of the ceph account.
# This parameter is mandatory.
#
# *key:*
# The key of the account. This parameter is mandatory.
# You can generate a key value with this command:
#
#     apt-get install ceph-common && ceph-authtool --gen-print-key
#
# *properties:*
# This parameter is an array of strings. Each string is
# a line in the keyring file. This parameter is mandatory.
#
# *owner:*
# The owner of the keyring file. This parameter is optional
# and its default value is 'root'.
#
# *group:*
# The group of the keyring file. This parameter is optional
# and its default value is 'root'.
#
# *mode:*
# The Unix rights of the keyring file. This parameter is optional
# and its default value is '0600'.
#
# == Sample Usages
#
#  ::ceph::common::keyring { 'ceph.client.cinder':
#    cluster_name => ceph,
#    account      => 'cinder',
#    key          => 'AQDN3ZJUUHKwGRAAgqki1QW271BYliGfmwzREA==',
#    # In properties, we define the capabilities of the account.
#    # Below typical capabilities to create and mount rbd images
#    # in a specific pool ("volumes" in this example).
#    properties   => [
#      'caps mon = "allow r"',
#      'caps osd = "allow class-read object_prefix rbd_children, allow rwx pool=volumes"'
#    ],
#    owner        => 'cinder',
#    group        => 'cinder',
#  }
#
#
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


